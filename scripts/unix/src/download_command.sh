## Check if git is installed
if ! command -v git >/dev/null 2>&1; then
	distro_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

	## Check operating system and install git accordingly
	if [[ -f "/etc/arch-release" ]]; then
		log_task "Installing git for Arch Linux"
		command_exec sudo pacman -Syu
		command_exec sudo pacman -S --needed --noconfirm git
	elif [[ "${distro_name}" == "Ubuntu" ]]; then
		log_task "Installing git for Ubuntu"
		command_exec sudo apt update --yes
		command_exec sudo apt install git --yes
	else
		error "To download dotfiles, you must have git."
	fi
fi

dotfiles_dir=$(expand_tilde "${args[target]}")
repo=${args[--repo]}
branch=${args[--branch]}
ssh=${args[--ssh]}

## Set remote depending on the ssh flag
if [[ -n "${ssh}" ]]; then
	remote="git@github.com:${repo}.git"
else
	remote="https://github.com/${repo}.git"
fi

## Check if dotfiles are already downloaded
if [[ -d "${dotfiles_dir}" ]]; then
	path=$(realpath "${dotfiles_dir}")

	log_task "Cleaning '${path}' with '${remote}' at branch '${branch}'"
	git="git -C ${path}"
	## Ensure that the remote is set to the correct URL
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
else
	log_task "Cloning '${repo}' at branch '${branch}' to '${dotfiles_dir}'"
	command_exec git clone -b "${branch}" "${remote}" "${dotfiles_dir}"
fi

log_success "Dotfiles downloaded to '${dotfiles_dir}'"
