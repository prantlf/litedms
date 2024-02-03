module routes

import compress.gzip { compress, decompress }
import encoding.html { escape }
import net.http { Request }
import os { exists, join_path_single, ls, read_file, rm, write_file_array }
import sync { new_rwmutex }
import prantlf.json { marshal }
import prantlf.strutil { index }
import debug { is_logging, log, log_str }
import helpers { escape_file_path, escape_url_path, unescape_file_path }

pub enum TextResult {
	plain
	html
	json
}

__global data = map[string]string{}
__global data_guard = new_rwmutex()

pub fn precache_texts() ! {
	log_str('listing files in storage')
	files := ls('storage')!
	for file in files {
		if file.ends_with('.txt.gz') {
			id := unescape_file_path(file[..file.len - 7])
			log('"%s" pre-cached as "%s"', file, id)
			data[id] = ''
		} else {
			log('"%s" ignored', file)
		}
	}
}

pub fn list_texts(req &Request) (TextResult, string) {
	log_str('listing texts')
	data_guard.@rlock()
	ids := data.keys()
	data_guard.runlock()

	if accept := req.header.get(.accept) {
		txt := check_accept(accept, 'text/plain')
		htm := check_accept(accept, 'text/html')
		app := check_accept(accept, 'application/')

		if app < txt && app < htm {
			out := marshal(ids)
			if is_logging() {
				log_str('listing ${ids.len} identifiers as json: ${limit_text(out)}')
			}
			return TextResult.json, out
		}

		if htm < txt {
			list := ids.map(fn (id string) string {
				return '  <li><a href="/texts/${escape(escape_url_path(id))}">${escape(id)}</a></li>'
			}).join('\n')
			out := '<ul>\n${list}\n</ul>'
			if is_logging() {
				log_str('listing ${ids.len} identifiers as html: ${limit_text(out)}')
			}
			return TextResult.html, out
		}
	}

	out := ids.map(fn (id string) string {
		return '* ${id}'
	}).join('\n')
	if is_logging() {
		log_str('listing ${ids.len} identifiers as text: ${limit_text(out)}')
	}
	return TextResult.plain, out
}

pub fn check_text(id string) ! {
	log('checking text "%s"', id)
	data_guard.@rlock()
	if val := data[id] {
		if val.len > 0 {
			data_guard.runlock()
			log('"%s" found in cache', id)
			return
		} else {
			log('"%s" was listed, but not cached yet', id)
		}
	}
	data_guard.runlock()

	path := get_text_path(id)
	if exists(path) {
		log('"%s" was found', path)
		return
	}

	log('"%s" was not found', path)
	return error_with_code('"${path}" does not exist', 404)
}

pub fn read_text(id string) !string {
	log('reading text "%s"', id)
	data_guard.@rlock()
	if val := data[id] {
		if val.len > 0 {
			data_guard.runlock()
			log('"%s" found in cache', id)
			return val
		} else {
			log('"%s" was listed, but not cached yet', id)
		}
	}
	data_guard.runlock()

	path := get_text_path(id)
	if exists(path) {
		data_guard.@lock()
		defer {
			data_guard.unlock()
		}
		if val := data[id] {
			if val.len > 0 {
				log('"%s" found in cache', id)
				return val
			}
		}

		log('"%s" was found', path)
		compressed := read_file(path)!
		log('%d bytes were read', compressed.len)
		decompressed := decompress(compressed.bytes())!
		text := unsafe { tos(decompressed.data, decompressed.len) }
		if is_logging() {
			log_str('decompressed ${text.len} bytes: "${limit_text(text)}"')
		}
		data[id] = text
		return text
	}

	log('"%s" was not found', path)
	return error_with_code('"${path}" does not exist', 404)
}

pub fn write_text(id string, req &Request) !bool {
	log('writing text "%s"', id)
	body := receive_body(req)!

	data_guard.@lock()
	defer {
		data_guard.unlock()
	}
	contains := id in data
	data[id] = body

	path := get_text_path(id)
	if is_logging() {
		log_str('writing "${limit_text(body)}" to ${path}')
	}
	bytes := compress(body.bytes())!
	write_file_array(path, bytes)!
	log('%d bytes were written', bytes.len)
	return contains
}

pub fn delete_text(id string) ! {
	log('deleting text "%s"', id)
	data_guard.@lock()
	defer {
		data_guard.unlock()
	}
	data.delete(id)

	path := get_text_path(id)
	if exists(path) {
		log('"%s" was found', path)
		rm(path)!
		log('"%s" was deleted', path)
	} else {
		return error_with_code('"${path}" does not exist', 404)
	}
}

@[inline]
fn get_text_path(id string) string {
	return join_path_single('storage', '${escape_file_path(id)}.txt.gz')
}

fn check_accept(accept string, typ string) int {
	// TODO: parse the value and use q to compare the priorities
	pos := index(accept, typ)
	return if pos < 0 {
		1_000_000
	} else {
		pos
	}
}

@[inline]
fn limit_text(text string) string {
	return if text.len > 360 {
		'${text[..178]}...${text[text.len - 179..]}'
	} else {
		text
	}
}

fn receive_body(req &Request) !string {
	body := req.data
	if encoding := req.header.get(.content_encoding) {
		if encoding == 'gzip' {
			log('compressed %d bytes received', body.len)
			decompressed := decompress(body.bytes()) or {
				return error_with_code('decompressing payload failed: ${err.msg()}', 400)
			}
			text := unsafe { tos(decompressed.data, decompressed.len) }
			if is_logging() {
				log_str('decompressed ${text.len} bytes: "${limit_text(text)}"')
			}
			return text
		}
		return error_with_code('unsupported encoding: "${encoding}"', 400)
	}

	if is_logging() {
		log_str('uncompressed ${body.len} bytes received: "${limit_text(body)}')
	}
	return body
}
