module helpers

import compress.gzip { compress }
import net.http { Request, Response }
import time { utc }
import prantlf.json { marshal }
import prantlf.strutil { index }
import config { Opts }
import debug { is_logging, log, log_str }

@[inline]
pub fn http_ok(mut res Response) {
	res.set_status(.ok)
}

@[inline]
pub fn http_201(mut res Response) {
	res.set_status(.created)
}

@[inline]
pub fn http_204(mut res Response) {
	res.set_status(.no_content)
}

@[inline]
pub fn http_400(mut res Response) {
	res.set_status(.bad_request)
}

@[inline]
pub fn http_404(mut res Response) {
	res.set_status(.not_found)
}

@[inline]
pub fn http_500(mut res Response) {
	res.set_status(.internal_server_error)
}

pub fn http_405(mut res Response, methods string) {
	log('method not %s', methods)
	res.set_status(.method_not_allowed)
	res.header.add(.allow, methods)
	res.header.add(.content_length, '0')
}

@[inline]
pub fn no_content(mut res Response) {
	log_str('sending empty response')
	res.header.add(.content_length, '0')
}

@[inline]
pub fn content_html(mut res Response) {
	res.header.add(.content_type, 'text/html')
}

@[inline]
pub fn content_json(mut res Response) {
	res.header.add(.content_type, 'application/json')
}

@[inline]
pub fn content_plain(mut res Response) {
	res.header.add(.content_type, 'text/plain')
}

@[inline]
pub fn content_yaml(mut res Response) {
	res.header.add(.content_type, 'application/yaml')
}

pub fn common_headers(mut res Response) {
	res.header.add(.server, 'LiteDMS')
	gmt := utc()
	mut date := gmt.strftime('---, %d --- %Y %H:%M:%S GMT')
	date = date.replace_once('---', gmt.weekday_str())
	date = date.replace_once('---', gmt.smonth())
	res.header.add(.date, date)
}

pub fn cors_headers(req &Request, mut res Response, methods string, opts &Opts) {
	if origin := req.header.get(.origin) {
		log('enabling cors for %s with %s for %ds', origin, methods, opts.cors_maxage)
		res.header.add(.access_control_allow_origin, origin)
		res.header.add(.access_control_allow_methods, methods)
		res.header.add(.access_control_allow_headers, 'Content-Type')
		res.header.add(.access_control_max_age, opts.cors_maxage.str())
		res.header.add(.vary, 'Accept-Encoding, Origin')
	}
}

pub fn preflight(req &Request, mut res Response, methods string, opts &Opts) {
	log('preflighting for %s', methods)
	http_204(mut res)
	common_headers(mut res)
	cors_headers(req, mut res, methods, opts)
	res.header.add(.connection, 'Keep-Alive')
	res.header.add(.keep_alive, 'timeout=2, max=100')
}

pub fn respond_body(req &Request, mut res Response, body string, opts &Opts) {
	if body.len >= opts.compression_limit {
		if accept := req.header.get(.accept_encoding) {
			if accept.contains('gzip') {
				if bytes := compress(body.bytes()) {
					res.header.add(.content_encoding, 'gzip')
					res.header.add(.content_length, bytes.len.str())
					log('sending compressed %d bytes', bytes.len)
					res.body = unsafe { tos(bytes.data, bytes.len) }
					return
				} else {
					if is_logging() {
						log_str('compression failed: ${err.msg()}')
					}
				}
			}
		}
	}
	log('sending uncompressed %d bytes', body.len)
	res.header.add(.content_length, body.len.str())
	res.body = body
}

pub fn respond_json(req &Request, mut res Response, body string, methods string, opts &Opts) {
	common_headers(mut res)
	cors_headers(req, mut res, methods, opts)
	content_json(mut res)
	respond_body(req, mut res, body, opts)
}

pub fn fail(req &Request, mut res Response, err IError, methods string, opts &Opts) {
	msg := err.msg()
	status := err.code()
	println('  failed: ${status}
  ${msg}')

	match status {
		400 {
			http_400(mut res)
		}
		404 {
			http_404(mut res)
		}
		else {
			http_500(mut res)
		}
	}

	common_headers(mut res)
	cors_headers(req, mut res, methods, opts)

	if status > 0 {
		body := if accept := req.header.get(.accept) {
			// TODO: parse the value and use q to compare the priorities
			app := index(accept, 'application/')
			if app >= 0 {
				content_json(mut res)
				'{"error":${marshal(msg)}}'
			} else {
				content_plain(mut res)
				msg
			}
		} else {
			content_plain(mut res)
			msg
		}
		respond_body(req, mut res, body, opts)
	} else {
		no_content(mut res)
	}
}
