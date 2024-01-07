module helpers

fn test_escape_url_path_valid() {
	assert escape_url_path('') == ''
	assert escape_url_path(url_path_valid_chars) == url_path_valid_chars
}

fn test_escape_url_path_invalid() {
	assert escape_url_path('/') == '%2F'
	assert escape_url_path('//') == '%2F%2F'
	assert escape_url_path('/a') == '%2Fa'
	assert escape_url_path('a/') == 'a%2F'
	assert escape_url_path('/a/') == '%2Fa%2F'
	assert escape_url_path('a/b') == 'a%2Fb'
}

fn test_unescape_url_path_not_needed() {
	assert unescape_url_path('') == ''
	assert unescape_url_path(url_path_valid_chars) == url_path_valid_chars
}

fn test_unescape_url_path_needed() {
	assert unescape_url_path('%2F') == '/'
	assert unescape_url_path('a%2F') == 'a/'
	assert unescape_url_path('%2Fa') == '/a'
	assert unescape_url_path('%2fa%2f') == '/a/'
}
