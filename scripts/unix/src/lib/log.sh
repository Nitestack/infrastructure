log_color() {
	local color_code="$1"
	shift

	printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}
log_green() {
	log_color "0;32" "$@"
}
start_task() {
	echo "󰪥" "$@"
}
complete_task() {
	log_green "" "$@"
}
