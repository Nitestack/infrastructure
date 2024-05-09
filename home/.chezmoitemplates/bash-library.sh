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

function log_task() {
	log_blue " TASK:" "$@"
}
function log_manual_action() {
	log_red " MANUAL ACTION REQUIRED:" "$@"
}
function log_error() {
	log_red " ERROR:" "$@"
}
function log_info() {
	log_blue " INFO:" "$@"
}
function log_success() {
	log_green " SUCCESS:" "$@"
}
function log_warning() {
	log_yellow " WARNING:" "$@"
}

function log_command() {
	log_yellow " COMMAND:" "$@"
}
function command_exec() {
	log_command "$@"
	"$@" || log_error "Command failed: $*"
}

function error() {
	log_error "$@"
	exit 1
}

function apt_ensure_installed() {
	local package_name="$1"
	shift

	if dpkg-query -W "${package_name}" &>/dev/null; then
		log_info "apt: Package '${package_name}' is already installed. Skipping."
		return
	fi

	log_task "apt: Installing package '${package_name}'"
	command_exec sudo apt install -y "${package_name}"
}

function pacman_ensure_installed() {
	local package_name="$1"
	shift

	if pacman -Qi "${package_name}" &>/dev/null; then
		log_info "pacman: Package '${package_name}' is already installed. Skipping."
		return
	fi

	log_task "pacman: Installing package '${package_name}'"
	command_exec sudo pacman -S --needed --noconfirm "${package_name}"
}

function brew_ensure_formula_installed() {
	local formula="$1"
	shift

	if brew list "${formula}" &>/dev/null; then
		log_info "brew: Formula '${formula}' is already installed. Skipping."
		return
	fi

	log_task "brew: Installing formula '${formula}'"
	command_exec brew install "${formula}"
}

function brew_ensure_cask_installed() {
	local cask="$1"
	shift

	if brew list --cask "${cask}" &>/dev/null; then
		log_info "brew: Cask '${cask}' is already installed. Skipping."
		return
	fi

	log_task "brew: Installing cask '${cask}'"
	command_exec brew install --cask "${cask}"
}
