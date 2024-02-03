log_color() {
	color_code="$1"
	shift

	printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}
log_red() {
	log_color "0;31" "$@"
}
log_blue() {
	log_color "0;34" "$@"
}
log_yellow() {
	log_color "0;33" "$@"
}
log_green() {
	log_color "0;32" "$@"
}

log_task() {
	log_blue " TASK:" "$@"
}
log_manual_action() {
	log_red " MANUAL ACTION REQUIRED:" "$@"
}
log_error() {
	log_red " ERROR:" "$@"
}
log_info() {
	log_blue " INFO:" "$@"
}
log_success() {
	log_green " SUCCESS:" "$@"
}
log_command() {
	log_yellow " COMMAND:" "$@"
}
command_exec() {
	log_command "$@"
	"$@" || log_error "Command failed: $*"
}
error() {
	log_error "$@"
	exit 1
}
