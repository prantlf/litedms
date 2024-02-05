import net.http { Request, Response }
import config { Opts }
import helpers {
	common_headers,
	content_html,
	content_json,
	content_plain,
	content_yaml,
	cors_headers,
	fail,
	http_200,
	http_201,
	http_204,
	http_404,
	http_405,
	no_content,
	preflight,
	respond_body,
	respond_json,
	unescape_url_path,
}
import debug { log_str, reset_ticking }
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

struct Router {
	opts    &Opts
	stopper chan bool
}

fn (r Router) handle(req Request) Response {
	reset_ticking()
	method := req.method
	path := req.url
	println('${method} ${path}')

	opts := r.opts
	mut res := Response{}

	if path == '/' {
		match method {
			.get {
				http_200(mut res)
				respond_json(req, mut res, routes.root, get_only, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/ping' {
		match method {
			.get {
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
		match method {
			.post {
				http_204(mut res)
				common_headers(mut res)
				cors_headers(req, mut res, post_only, opts)
				no_content(mut res)
				r.stopper <- true
			}
			.options {
				preflight(req, mut res, post_only, opts)
			}
			else {
				http_405(mut res, post_only)
			}
		}
	} else if path == '/docs' {
		match method {
			.get {
				http_200(mut res)
				common_headers(mut res)
				content_html(mut res)
				respond_body(req, mut res, routes.docs, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/openapi' {
		match method {
			.get {
				http_200(mut res)
				common_headers(mut res)
				cors_headers(req, mut res, get_only, opts)
				content_yaml(mut res)
				respond_body(req, mut res, routes.openapi, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path == '/texts' {
		match method {
			.get {
				typ, content := list_texts(req)
				http_200(mut res)
				common_headers(mut res)
				cors_headers(req, mut res, post_only, opts)
				match typ {
					.plain {
						content_plain(mut res)
					}
					.html {
						content_html(mut res)
					}
					.json {
						content_json(mut res)
					}
				}
				respond_body(req, mut res, content, opts)
			}
			else {
				http_405(mut res, get_only)
			}
		}
	} else if path.starts_with('/texts/') {
		match method {
			.head {
				if _ := check_text(unescape_url_path(path[7..])) {
					http_204(mut res)
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					no_content(mut res)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			.get {
				if content := read_text(unescape_url_path(path[7..])) {
					http_200(mut res)
					common_headers(mut res)
					cors_headers(req, mut res, head_get_put_delete, opts)
					content_plain(mut res)
					respond_body(req, mut res, content, opts)
				} else {
					fail(req, mut res, err, head_get_put_delete, opts)
				}
			}
			.put {
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
			.delete {
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
		http_404(mut res)
	}

	res.set_version(.v1_1)
	log_str('flushing the response')
	return res
}
