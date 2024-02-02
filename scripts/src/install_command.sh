## Check if chezmoi is installed
if ! chezmoi="$(command -v chezmoi)"; then
	bin_dir=$(expand_tilde "${args[--bin]}")
	chezmoi="${bin_dir}/chezmoi"

	## Check operating system and install chezmoi accordingly
	if [[ -f "/etc/arch-release" ]]; then
		log_task "Installing chezmoi for Arch Linux"
		command_exec sudo pacman -Syu
		command_exec sudo pacman -S --needed --noconfirm chezmoi
	else
		log_task "Installing chezmoi to '${chezmoi}'"
		if command -v curl >/dev/null; then
			chezmoi_install_script="$(curl -fsSL https://get.chezmoi.io)"
		elif command -v wget >/dev/null; then
			chezmoi_install_script="$(wget -qO- https://get.chezmoi.io)"
		else
			error "To install chezmoi, you must have curl or wget."
		fi
		command_exec sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
		unset chezmoi_install_script bin_dir
	fi
fi

sourceDir=$(expand_tilde "${args[sourceDir]}")

set -- --source="${sourceDir}" --verbose=false

if [[ -n "${args["--one-shot"]}" ]]; then
	set -- "$@" --one-shot
else
	set -- "$@" --apply
fi

if [[ -n "${args[--debug]}" ]]; then
	set -- "$@" --debug
fi

command_exec chezmoi init "$@"

log_success "Installed dotfiles"
