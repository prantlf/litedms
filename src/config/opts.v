module config

import os { getenv_opt }
import strconv { atoi, parse_uint }

pub const version = '0.1.0'

pub struct Opts {
pub mut:
	host              string = '0.0.0.0'
	port              u16    = 8020
	compression_limit int    = 1024
	cors_maxage       int    = 86400
}

pub fn init_opts() !&Opts {
	mut opts := &Opts{}
	if host := getenv_opt('LITEDMS_HOST') {
		opts.host = host
	}
	if port := getenv_opt('LITEDMS_PORT}') {
		opts.port = u16(parse_uint(port, 10, 16)!)
	}
	if compression_limit := getenv_opt('LITEDMS_COMPRESSION_LIMIT') {
		opts.compression_limit = atoi(compression_limit)!
	}
	if cors_maxage := getenv_opt('LITEDMS_CORS_MAXAGE') {
		opts.cors_maxage = atoi(cors_maxage)!
	}
	return opts
}
