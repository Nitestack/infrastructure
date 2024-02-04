## Check for local/global updates
if [[ -n "${args[--local]}" ]]; then
	set -- apply
else
	set -- update
fi

if [[ -n "${args["--refresh-externals"]}" ]]; then
	set -- "$@" --refresh-externals="${args["--refresh-externals"]}"
fi

command_exec chezmoi "$@"
log_success "Updated dotfiles"

## Update the CLI
if [[ -n "${args["--cli"]}" ]]; then
	script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)/dotfiles"

	updated_script_dir=$(realpath "$(chezmoi source-path)/../scripts/unix/dotfiles")

	log_task "Replacing CLI executable in '${script_dir}'"
	command_exec cp -f "${updated_script_dir}" "${script_dir}"
	log_success "Updated the CLI to the latest version"
fi

## Update Neovim related files
if [[ -n "${args["--nvim"]}" ]]; then
	## Update Neovim
	log_task "Updating Neovim"
	command_exec bob update --all
	log_success "Updated Neovim to the latest version"

	## Update Lazy plugins and Mason packages
	log_task "Updating Neovim plugins"
	command_exec nvim --headless -c "lua vim.schedule(function() require('lazy').sync(); vim.cmd('qa!') end)"
	log_success "Updated Neovim plugins"

	log_task "Updating Mason packages"
	command_exec nvim --headless -c "lua vim.schedule(function() require('mason-tool-installer').check_install(true); vim.cmd('qa!') end)"
	log_success "Updated Mason packages"

	## Sync lazy-lock.json file
	log_task "Syncing 'lazy.lock.json' file"
	source_path=$(chezmoi source-path)
	lazy_lock_path=$(find "${source_path}" -type f -name "*lazy-lock.json" -print -quit)
	if [[ ! -f "${lazy_lock_path}" ]]; then
		error "Could not find 'lazy-lock.json' file in '${source_path}'"
	fi
	config_path="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
	updated_lazy_lock_path=$(find "${config_path}" -type f -name "*lazy-lock.json" -print -quit)
	if [[ ! -f "${updated_lazy_lock_path}" ]]; then
		error "Could not find 'lazy-lock.json' file in '${config_path}'"
	fi
	command_exec cp -f "${updated_lazy_lock_path}" "${lazy_lock_path}"
	log_success "Synced 'lazy-lock.json' file"

	## Commit the updated 'lazy-lock.json' file
	## Check if there are any changes
	if git diff --exit-code -- "${lazy_lock_path}"; then
		log_info "No changes in 'lazy-lock.json' file. Skip committing."
		exit 0
	fi
	git="git -C $(realpath "$(chezmoi source-path)/..")"
	command_exec "${git}" add "${lazy_lock_path}" || error "Could not add 'lazy-lock.json' file"
	command_exec "${git}" commit "${lazy_lock_path}" -m "chore(nvim): update lazy-lock.json"
	log_success "Committed 'lazy-lock.json' file"
fi
