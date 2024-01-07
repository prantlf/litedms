module helpers

import compress.gzip { compress }
import net.http { CommonHeader }
import picohttpparser { Request, Response }
import prantlf.json { marshal }
import prantlf.strutil { index }
import config { Opts }
import debug { is_logging, log, log_str }

pub fn get_header(req &Request, key CommonHeader) ?string {
	name := key.str()
	for header in req.headers {
		if header.name == name {
			return header.value
		}
	}
	return none
}

@[inline]
pub fn http_201(mut res Response) {
	res.raw('HTTP/1.1 201 Created\r\n')
}

@[inline]
pub fn http_204(mut res Response) {
	res.raw('HTTP/1.1 204 No Content\r\n')
}

@[inline]
pub fn http_400(mut res Response) {
	res.raw('HTTP/1.1 400 Bad Request\r\n')
}

@[inline]
pub fn http_404(mut res Response) {
	res.raw('HTTP/1.1 404 Not Found\r\n')
}

@[inline]
pub fn http_500(mut res Response) {
	res.raw('HTTP/1.1 500 Internal Server Error\r\n')
}

@[inline]
pub fn http_405(mut res Response, methods string) {
	log('method not %s', methods)
	res.raw('HTTP/1.1 405 Method Not Allowed\r\nAllow: ${methods}\r\nContent-Length: 0\r\n\r\n')
}

@[inline]
pub fn no_content(mut res Response) {
	log_str('sending empty response')
	res.raw('Content-Length: 0\r\n\r\n')
}

@[inline]
pub fn common_headers(mut res Response) {
	res.header_server()
	res.header_date()
}

pub fn cors_headers(req &Request, mut res Response, methods string, opts &Opts) {
	if origin := get_header(req, CommonHeader.origin) {
		log('enabling cors for %s with %s for %ds', origin, methods, opts.cors_maxage)
		res.raw('Access-Control-Allow-Origin: ${origin}\r\nAccess-Control-Allow-Methods: ${methods}\r\nAccess-Control-Allow-Headers: Content-Type\r\nAccess-Control-Max-Age: ${opts.cors_maxage}\r\nVary: Accept-Encoding, Origin\r\n')
	}
}

pub fn preflight(req &Request, mut res Response, methods string, opts &Opts) {
	log('preflighting for %s', methods)
	http_204(mut res)
	common_headers(mut res)
	cors_headers(req, mut res, methods, opts)
	res.raw('Keep-Alive: timeout=2, max=100\r\nConnection: Keep-Alive\r\n\r\n')
}

pub fn respond_body(req &Request, mut res Response, body string, opts &Opts) {
	if body.len >= opts.compression_limit {
		if accept := get_header(req, .accept_encoding) {
			if accept.contains('gzip') {
				if bytes := compress(body.bytes()) {
					res.header('Content-Encoding', 'gzip')
					log('sending compressed %d bytes', bytes.len)
					res.body(unsafe { tos(bytes.data, bytes.len) })
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
	res.body(body)
}

pub fn respond_json(req &Request, mut res Response, body string, methods string, opts &Opts) {
	common_headers(mut res)
	cors_headers(req, mut res, methods, opts)
	res.json()
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
		body := if accept := get_header(req, .accept) {
			// TODO: parse the value and use q to compare the priorities
			app := index(accept, 'application/')
			if app >= 0 {
				res.json()
				'{"error":${marshal(msg)}}'
			} else {
				res.plain()
				msg
			}
		} else {
			res.plain()
			msg
		}
		respond_body(req, mut res, body, opts)
	} else {
		no_content(mut res)
	}
}
