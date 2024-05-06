import net.http { Server, WaitTillRunningParams }
import os { Signal, mkdir_all, signal_opt }
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

fn stop(mut server Server, ch chan bool) {
	log_str('stopping...')
	ch.close()
	server.wait_till_running(WaitTillRunningParams{}) or {
		println('stopping failed: ${err.msg()}')
	}
	log_str('stopped')
	exit(0)
}

fn run() ! {
	load_env(true)!
	opts := init_opts()!

	println('Initialising the storage.')
	log_str('ensuring storage directory')
	mkdir_all(opts.storage)!
	precache_texts(opts.storage)!

	addr := '${opts.host}:${opts.port}'
	stopper := chan bool{cap: 1}
	mut server := Server{
		addr: addr
		handler: Router{
			opts: opts
			stopper: stopper
		}
	}
	mut server_ref := &server

	signal_opt(.int, fn [stopper] (_signal Signal) {
		stopper <- true
	})!
	signal_opt(.term, fn [stopper] (_signal Signal) {
		stopper <- true
	})!

	spawn fn [mut server_ref] (ch chan bool) {
		_ := <-ch
		stop(mut server_ref, ch)
	}(stopper)

	server.listen_and_serve()
}
