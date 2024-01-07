module helpers

import strings { Builder, new_builder }

const url_path_valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~!$&'()*+,;=:@"
const file_path_invalid_chars = '/\\:;?*'

@[direct_array_access]
pub fn escape_url_path(part string) string {
	len := part.len
	mut i := 0
	for ; i < len && helpers.url_path_valid_chars.contains_u8(part[i]); i++ {}
	if i == len {
		return part
	}

	mut buf := new_builder(i + (len - i) * 3)
	if i > 0 {
		unsafe { buf.write_ptr(part.str, i) }
	}
	write_escaped(part[i], mut buf)

	i++
	for ; i < len; i++ {
		ch := part[i]
		if helpers.url_path_valid_chars.contains_u8(part[i]) {
			buf.write_u8(ch)
		} else {
			write_escaped(ch, mut buf)
		}
	}

	return buf.str()
}

fn write_escaped(ch u8, mut buf Builder) {
	buf.write_u8(`%`)
	buf.write_u8(hex_digit((ch >> 4) & 0x0F))
	buf.write_u8(hex_digit(ch & 0x0F))
}

@[inline]
fn hex_digit(n u8) u8 {
	return if n < 10 { n + `0` } else { n + 55 }
}

@[direct_array_access]
pub fn unescape_url_path(part string) string {
	len := part.len
	mut i := 0
	for ; i < len; i++ {
		ch := part[i]
		if ch == `%` {
			if i + 2 < len {
				break
			} else {
				return part
			}
		}
	}
	if i == len {
		return part
	}

	mut buf := new_builder(len)
	if i > 0 {
		unsafe { buf.write_ptr(part.str, i) }
	}
	write_unescaped(part[i + 1], part[i + 2], mut buf)

	i += 3
	for ; i < len; i++ {
		ch := part[i]
		if ch == `%` {
			if i + 2 < len {
				write_unescaped(part[i + 1], part[i + 2], mut buf)
				i += 2
			} else {
				buf.write_u8(ch)
				buf.write_u8(part[i + 1])
				break
			}
		} else {
			buf.write_u8(ch)
		}
	}

	return buf.str()
}

fn write_unescaped(digit_upper u8, digit_lower u8, mut buf Builder) {
	upper := hex_atoi(digit_upper)
	if upper != 255 {
		lower := hex_atoi(digit_lower)
		if lower != 255 {
			buf.write_u8((upper << 4) | lower)
			return
		}
	}
	buf.write_u8(`%`)
	buf.write_u8(digit_upper)
	buf.write_u8(digit_lower)
}

fn hex_atoi(digit u8) u8 {
	if digit >= `0` && digit <= `9` {
		return digit - 48
	}
	letter := digit & ~32
	if letter >= `A` && letter <= `F` {
		return letter - 55
	}
	return 255
}

@[direct_array_access]
pub fn escape_file_path(part string) string {
	len := part.len
	mut i := 0
	for ; i < len && !helpers.file_path_invalid_chars.contains_u8(part[i]); i++ {}
	if i == len {
		return part
	}

	mut buf := new_builder(i + (len - i) * 3)
	if i > 0 {
		unsafe { buf.write_ptr(part.str, i) }
	}
	write_escaped(part[i], mut buf)

	i++
	for ; i < len; i++ {
		ch := part[i]
		if helpers.file_path_invalid_chars.contains_u8(part[i]) {
			write_escaped(ch, mut buf)
		} else {
			buf.write_u8(ch)
		}
	}

	return buf.str()
}

@[inline]
pub fn unescape_file_path(part string) string {
	return unescape_url_path(part)
}
