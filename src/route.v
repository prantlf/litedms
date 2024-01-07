import picohttpparser { Request, Response }
import config { Opts }
import helpers {
	common_headers,
	cors_headers,
	fail,
	http_201,
	http_204,
	http_405,
	no_content,
	preflight,
	respond_body,
	respond_json,
	unescape_url_path,
}
import debug { log_str }
import routes {
	check_text,
	delete_text,
	list_texts,
	read_text,
	write_text,
}

const get_only = 'GET'
const head_get_put_delete = 'HEAD, GET, PUT, DELETE'
const post_only = 'POST'

fn route(data voidptr, req Request, mut res Response) {
	println('${req.method} ${req.path}')

	opts := unsafe { &Opts(data) }
	path := req.path

	if path == '/' {
		match req.method {
			'GET' {
				res.http_ok()
				respond_json(req, mut res, routes.root, get_only, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/ping' {
		match req.method {
			'GET' {
				http_204(mut res)
				common_headers(mut res)
				cors_headers(req, mut res, get_only, opts)
				no_content(mut res)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/shutdown' {
		match req.method {
			'POST' {
				http_204(mut res)
				common_headers(mut res)
				cors_headers(req, mut res, post_only, opts)
				no_content(mut res)
				res.end()
				exit(0)
			}
			'OPTIONS' {
				preflight(req, mut res, post_only, opts)
			}
			else {
				http_405(mut res, post_only)
			}
		}
	} else if path == '/docs' {
		match req.method {
			'GET' {
				res.http_ok()
				common_headers(mut res)
				res.html()
				respond_body(req, mut res, routes.docs, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/openapi' {
		match req.method {
			'GET' {
				res.http_ok()
				common_headers(mut res)
				cors_headers(req, mut res, get_only, opts)
				res.content_type('application/yaml')
				respond_body(req, mut res, routes.openapi, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/texts' {
		match req.method {
			'GET' {
				typ, content := list_texts(req)
				res.http_ok()
				common_headers(mut res)
				cors_headers(req, mut res, post_only, opts)
				match typ {
					.plain {
						res.plain()
					}
					.html {
						res.html()
					}
					.json {
						res.json()
					}
				}
				respond_body(req, mut res, content, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path.starts_with('/texts/') {
		match req.method {
			'HEAD' {
				if _ := check_text(unescape_url_path(path[7..])) {
					http_204(mut res)
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					no_content(mut res)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			'GET' {
				if content := read_text(unescape_url_path(path[7..])) {
					res.http_ok()
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					res.plain()
					respond_body(req, mut res, content, opts)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			'PUT' {
				if updated := write_text(unescape_url_path(path[7..]), req) {
					if updated {
						http_204(mut res)
					} else {
						http_201(mut res)
					}
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					no_content(mut res)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			'DELETE' {
				if _ := delete_text(unescape_url_path(path[7..])) {
					http_204(mut res)
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					no_content(mut res)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			else {
				http_405(mut res, head_get_put_delete)
			}
		}
	} else {
		res.http_404()
	}

	log_str('flushing the response')
	res.end()
	log_str('request processed')
}
