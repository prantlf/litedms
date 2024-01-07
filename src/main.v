import os { mkdir_all }
import picoev
import prantlf.dotenv { load_env }
import config { init_opts }
import debug { log_str }
import routes { precache_texts }

fn main() {
	run() or {
		eprintln(err.msg())
		exit(1)
	}
}

fn run() ! {
	load_env(true)!
	opts := init_opts()!

	println('initialising the storage...')
	log_str('ensuring storage directory')
	mkdir_all('storage')!
	precache_texts()!

	println('listening on http://${opts.host}:${opts.port}/...')
	mut server := picoev.new(
		host: opts.host
		port: opts.port
		cb: route
		user_data: unsafe { opts }
	)
	server.serve()
}
