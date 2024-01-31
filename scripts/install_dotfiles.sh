#!/bin/bash

# -e: exit on error
# -u: exit on unset variables
set -eu

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

log_task() {
	log_blue "🔃" "$@"
}

log_manual_action() {
	log_red "⚠️" "$@"
}

log_error() {
	log_red "❌" "$@"
}

error() {
	log_error "$@"
	exit 1
}

git_clean() {
	path=$(realpath "$1")
	remote="$2"
	branch="$3"

	log_task "Cleaning '${path}' with '${remote}' at branch '${branch}'"
	git="git -C ${path}"
	# Ensure that the remote is set to the correct URL
	if ${git} remote | grep -q "^origin$"; then
		${git} remote set-url origin "${remote}"
	else
		${git} remote add origin "${remote}"
	fi
	${git} checkout -B "${branch}"
	${git} fetch origin "${branch}"
	${git} reset --hard FETCH_HEAD
	${git} clean -fdx
	unset path remote branch git
}

# User configuration
DOTFILES_REPO_HOST=${DOTFILES_REPO_HOST:-"https://github.com"}
DOTFILES_USER=${DOTFILES_USER:-"Nitestack"}
DOTFILES_REPO="${DOTFILES_REPO_HOST}/${DOTFILES_USER}/dotfiles"
DOTFILES_BRANCH=${DOTFILES_BRANCH:-"master"}
DOTFILES_DIR="${HOME}/.dotfiles"

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
	distro_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

	# Check operating system and install git accordingly
	if [[ -f "/etc/arch-release" ]]; then
		log_task "Installing git for Arch Linux"
		sudo pacman -Syu
		sudo pacman -S --needed --noconfirm git
	elif [[ "${distro_name}" == "Ubuntu" ]]; then
		log_task "Installing git for Ubuntu"
		sudo apt update --yes
		sudo apt install git --yes
	else
		error "To install the dotfiles, you must have git."
	fi
fi

# Check if the dotfiles are installed
if [[ -d "${DOTFILES_DIR}" ]]; then
	git_clean "${DOTFILES_DIR}" "${DOTFILES_REPO}" "${DOTFILES_BRANCH}"
else
	log_task "Cloning '${DOTFILES_REPO}' at branch '${DOTFILES_BRANCH}' to '${DOTFILES_DIR}'"
	git clone --branch "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

# Check if an install script is available
if [[ -f "${DOTFILES_DIR}/install.sh" ]]; then
	INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
elif [[ -f "${DOTFILES_DIR}/install" ]]; then
	INSTALL_SCRIPT="${DOTFILES_DIR}/install"
else
	error "No install script found in the dotfiles."
fi

log_task "Running '${INSTALL_SCRIPT}'"
chmod +x "${INSTALL_SCRIPT}"
exec "${INSTALL_SCRIPT}" "$@"
