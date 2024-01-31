# shellcheck shell=bash

set -euo pipefail

if [[ -n "${DOTFILES_DEBUG:-}" ]]; then
	set -x
fi

function log_color() {
	local color_code="$1"
	shift

	printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}
function log_red() {
	log_color "0;31" "$@"
}
function log_blue() {
	log_color "0;34" "$@"
}
function log_green() {
	log_color "1;32" "$@"
}
function log_yellow() {
	log_color "1;33" "$@"
}

function log_task() {
	log_blue "🔃 TASK:" "$@"
}
function log_manual_action() {
	log_red "⚠️ MANUAL ACTION REQUIRED:" "$@"
}
function log_error() {
	log_red "❌ ERROR:" "$@"
}
function log_info() {
	log_blue "ℹ️ INFO:" "$@"
}
function log_success() {
	log_green "✅ SUCCESS:" "$@"
}
function log_warning() {
	log_yellow "⚠️ WARNING:" "$@"
}

function log_command() {
	log_yellow "👉 COMMAND:" "$@"
}
function command_exec() {
	log_command "$@"
	exec "$@"
}

function error() {
	log_error "$@"
	exit 1
}

function ensure_installed() {
	local cmd_name="$1"
	shift

	if command -v "${cmd_name}" >/dev/null 2>&1; then
		log_info "${cmd_name} is already installed. Skipping."
		return
	fi

	log_task "Installing ${cmd_name}"
	command_exec "$@"
}
