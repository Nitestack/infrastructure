expand_tilde() {
	local path="$1"
	echo "${path/#\~/${HOME}}"
}
