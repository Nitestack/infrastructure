# shellcheck shell=bash
# ╭──────────────────────────────────────────────────────────╮
# │ BASH LIBRARY                                             │
# ╰──────────────────────────────────────────────────────────╯

set -uo pipefail

echo

# Log functions
_log() {
	gum log -s "$@"
}

_spin() {
	title=$1
	shift

	gum spin --show-error --spinner points --title "${title}" "$@"
}

# Utils
_install_packages_pacman() {
	toInstall=()

	for pkg; do
		if pacman -Q "${pkg}" &>/dev/null; then
			_log -l warn --prefix "pacman" "${pkg} is already installed"
			continue
		fi
		toInstall+=("${pkg}")
	done

	if [[ "${toInstall[*]}" == "" ]]; then
		return
	fi

	sudo pacman --needed --noconfirm -S "${toInstall[@]}"
}

_install_packages_paru() {
	toInstall=()

	for pkg; do
		if paru -Q "${pkg}" &>/dev/null; then
			_log -l warn --prefix "paru" "${pkg} is already installed"
			continue
		fi
		toInstall+=("${pkg}")
	done

	if [[ "${toInstall[*]}" == "" ]]; then
		return
	fi

	paru --needed -S "${toInstall[@]}"
}
