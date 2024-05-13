# shellcheck shell=bash

set -euo pipefail

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

function start_loading() {
	local message="$1"
	shift

	printf "\033[1;33m%s\033[0m\r" "󰇘${message}" >&2
}

function stop_loading() {
	local message="$1"
	shift

	local is_success="${2:-""}"

	if [[ "${is_success}" == "--is-success" ]]; then
		emoji=""
	else
		emoji=""
	fi

	echo -en "\033[0K"
	log_green "${emoji} ${message}"
}

function log_task() {
	log_blue "" "$@"
}
function log_manual_action() {
	log_red "" "$@"
}
function log_error() {
	log_red "" "$@"
}
function log_info() {
	log_blue "" "$@"
}
function log_success() {
	log_green "" "$@"
}
function log_warning() {
	log_yellow "" "$@"
}

function log_command() {
	log_yellow "" "$@"
}
function command_exec() {
	"$@" || log_error "Command failed: $*"
}

function error() {
	log_error "$@"
	exit 1
}

function apt_ensure_installed() {
	local package_name="$1"
	shift

	start_loading "${package_name}"

	if dpkg-query -W "${package_name}" &>/dev/null; then
		stop_loading "${package_name}"
		return
	fi

	command_exec sudo apt install -y "${package_name}"
	stop_loading "${package_name}" --is-success
}

function pacman_ensure_installed() {
	local package_name="$1"
	shift

	start_loading "${package_name}"

	if pacman -Qi "${package_name}" &>/dev/null; then
		stop_loading "${package_name}"
		return
	fi

	command_exec sudo pacman -S --needed --noconfirm "${package_name}"
	stop_loading "${package_name}" --is-success
}

function brew_ensure_formula_installed() {
	local formula="$1"
	shift

	start_loading "${formula}"

	if brew list "${formula}" &>/dev/null; then
		stop_loading "${formula}"
		return
	fi

	log_task "brew: Installing formula '${formula}'"
	command_exec brew install "${formula}"
	stop_loading "${formula}" --is-success
}

function brew_ensure_cask_installed() {
	local cask="$1"
	shift

	start_loading "${cask}"

	if brew list --cask "${cask}" &>/dev/null; then
		stop_loading "${cask}"
		return
	fi

	command_exec brew install --cask "${cask}"
	stop_loading "${cask}" --is-success
}
