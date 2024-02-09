log_task "Updating dotfiles"

## Check for local/global updates
if [[ -n "${args[--local]}" ]]; then
	set -- apply
else
	set -- update
fi

if [[ -n "${args["--refresh-externals"]}" ]]; then
	set -- "$@" --refresh-externals="${args["--refresh-externals"]}"
fi

chezmoi "$@" || error "Failed to update dotfiles"
log_success "Updated dotfiles"

## Update the CLI
if [[ -n "${args["--cli"]}" ]]; then
	script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)/dotfiles"
	if [[ ! -f "${script_dir}" ]]; then
		error "Could not find '${script_dir}'"
	fi

	updated_script_dir=$(realpath "$(chezmoi source-path)/../scripts/unix/dotfiles")
	if [[ ! -f "${updated_script_dir}" ]]; then
		error "Could not find '${updated_script_dir}'"
	fi

	## Check if the CLI is already up to date
	if [[ "${script_dir}" == "${updated_script_dir}" ]]; then
		log_success "The CLI is already up to date"
		exit 0
	fi

	log_task "Updating CLI"
	cp -f "${updated_script_dir}" "${script_dir}" || error "Failed to sync 'dotfiles'"
	log_success "Updated the CLI to the latest version"
fi

## Update Neovim related files
if [[ -n "${args["--nvim"]}" ]]; then
	## Update Neovim
	log_task "Updating Neovim"
	bob update --all || error "Failed to update Neovim"
	log_success "Updated Neovim to the latest version"

	## Update Lazy plugins and Mason packages
	log_task "Updating Neovim plugins"
	nvim --headless -c "Lazy! sync" +qa || error "Failed to update Neovim plugins"
	log_success "Updated Neovim plugins"

	log_task "Updating Mason packages"
	nvim --headless -c "lua vim.schedule(function() vim.api.nvim_create_autocmd('User', { pattern = 'MasonToolsUpdateCompleted', command = 'qa' }); require('mason-tool-installer').check_install(true) end)" || error "Failed to update Mason packages"
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
	cp -f "${updated_lazy_lock_path}" "${lazy_lock_path}" || error "Failed to sync 'lazy-lock.json' file"
	log_success "Synced 'lazy-lock.json' file"

	## Commit the updated 'lazy-lock.json' file
	log_task "Committing 'lazy-lock.json' file"
	## Check if there are any changes
	if git diff --quiet --exit-code -- "${lazy_lock_path}"; then
		log_info "No changes in 'lazy-lock.json' file. Skip committing."
		exit 0
	fi
	current_path=$(pwd)
	cd "$(realpath "$(chezmoi source-path)/..")" || error "Failed to set current path to '$(chezmoi source-path)/..'"
	git add "${lazy_lock_path}" || error "Failed to add 'lazy-lock.json' file to git"
	git commit "${lazy_lock_path}" -m "chore(nvim): update lazy-lock.json" || error "Failed to commit 'lazy-lock.json' file"
	log_success "Committed 'lazy-lock.json' file"
	cd "${current_path}" || error "Failed to set current path to '${current_path}'"
fi
