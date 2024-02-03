module debug

import prantlf.debug as debug_impl

const d = debug_impl.new_debug('litedms')

@[inline]
pub fn log(format string, arguments ...voidptr) {
	debug.d.log(format, ...arguments)
}

@[inline]
pub fn log_str(s string) {
	debug.d.log_str(s)
}

@[inline]
pub fn is_logging() bool {
	return debug.d.is_enabled()
}

@[inline]
pub fn reset_ticking() {
	debug.d.set_ticks()
}
