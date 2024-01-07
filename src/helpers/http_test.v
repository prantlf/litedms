module helpers

import strings { new_builder }
import picohttpparser { Header, Request, Response }
import config { Opts }

fn test_get_header_hit() {
	mut headers := [100]Header{}
	headers[0] = Header{
		name: 'Accept'
		value: 'text/plain'
	}
	req := Request{
		headers: headers
	}
	assert get_header(req, .accept)? == 'text/plain'
}

fn test_get_header_miss() {
	req := Request{
		headers: [100]Header{}
	}
	get_header(req, .accept_encoding) or { return }
	assert false
}

fn test_send_content_small() {
	req := Request{
		headers: [100]Header{}
	}
	buf := []u8{len: 2048}
	mut res := Response{
		buf_start: unsafe { buf.data }
		buf: unsafe { buf.data }
	}
	respond_body(req, mut res, 'test', &Opts{})
	out := unsafe { tos(res.buf_start, res.buf - res.buf_start) }
	assert out == 'Content-Length: 4\r\n\r\ntest'
}

fn test_send_content_no_header() {
	req := Request{
		headers: [100]Header{}
	}
	buf := []u8{len: 2048}
	mut res := Response{
		buf_start: unsafe { buf.data }
		buf: unsafe { buf.data }
	}
	body := produce_kb()
	respond_body(req, mut res, body, &Opts{})
	out := unsafe { tos(res.buf_start, res.buf - res.buf_start) }
	assert out == 'Content-Length: 1024\r\n\r\n${body}'
}

fn test_send_content_unsupported_header() {
	mut headers := [100]Header{}
	headers[0] = Header{
		name: 'Accept-Encoding'
		value: 'br'
	}
	req := Request{
		headers: headers
	}
	buf := []u8{len: 2048}
	mut res := Response{
		buf_start: unsafe { buf.data }
		buf: unsafe { buf.data }
	}
	body := produce_kb()
	respond_body(req, mut res, body, &Opts{})
	out := unsafe { tos(res.buf_start, res.buf - res.buf_start) }
	assert out == 'Content-Length: 1024\r\n\r\n${body}'
}

fn test_send_content_compressed() {
	mut headers := [100]Header{}
	headers[0] = Header{
		name: 'Accept-Encoding'
		value: 'gzip'
	}
	req := Request{
		headers: headers
	}
	buf := []u8{len: 2048}
	mut res := Response{
		buf_start: unsafe { buf.data }
		buf: unsafe { buf.data }
	}
	body := produce_kb()
	respond_body(req, mut res, body, &Opts{})
	out := unsafe { tos(res.buf_start, res.buf - res.buf_start) }
	assert out.starts_with('Content-Encoding: gzip\r\nContent-Length: 257')
}

fn produce_kb() string {
	mut buf := new_builder(1024)
	for i in 0 .. 256 {
		buf.write_string('test')
	}
	return buf.str()
}
