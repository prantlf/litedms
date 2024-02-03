module helpers

import net.http { Request, Response }
import strings { new_builder }
import config { Opts }

const first_line = 'HTTP/1.1 200 OK\r\n'

fn init_call() (Request, Response) {
	req := Request{}
	mut res := Response{}
	res.set_version(.v1_1)
	res.set_status(.ok)
	return req, res
}

fn produce_kb() string {
	mut buf := new_builder(1024)
	for i in 0 .. 256 {
		buf.write_string('test')
	}
	return buf.str()
}

@[inline]
fn check_output(res &Response, expect string) {
	assert res.bytestr() == '${helpers.first_line}${expect}'
}

fn test_send_content_small() {
	req, mut res := init_call()
	respond_body(req, mut res, 'test', &Opts{})
	check_output(res, 'Content-Length: 4\r\n\r\ntest')
}

fn test_send_content_no_header() {
	req, mut res := init_call()
	body := produce_kb()
	respond_body(req, mut res, body, &Opts{})
	check_output(res, 'Content-Length: 1024\r\n\r\n${body}')
}

fn test_send_content_unsupported_header() {
	mut req, mut res := init_call()
	req.add_header(.accept_encoding, 'br')
	body := produce_kb()
	respond_body(req, mut res, body, &Opts{})
	check_output(res, 'Content-Length: 1024\r\n\r\n${body}')
}

fn test_send_content_compressed() {
	mut req, mut res := init_call()
	req.add_header(.accept_encoding, 'gzip')
	respond_body(req, mut res, produce_kb(), &Opts{})
	assert res.bytestr().starts_with('HTTP/1.1 200 OK\r\nContent-Encoding: gzip\r\nContent-Length: 257')
}
