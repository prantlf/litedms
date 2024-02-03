import net.http { Server, WaitTillRunningParams }
import os { mkdir_all }
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

	println('Initialising the storage.')
	log_str('ensuring storage directory')
	mkdir_all('storage')!
	precache_texts()!

	addr := '${opts.host}:${opts.port}'
	stopper := chan bool{cap: 1}
	mut server := Server{
		addr: addr
		handler: Router{
			opts: opts
			stopper: stopper
		}
	}
	server.listen_and_serve()
}
