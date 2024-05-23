start_task "Updating dotfiles"

## Check for local/global updates
if [[ -n "${args[--local]}" ]]; then
	set -- apply
else
	set -- update
fi

if [[ -n "${args["--refresh-externals"]}" ]]; then
	set -- "$@" --refresh-externals="${args["--refresh-externals"]}"
fi

chezmoi "$@"
complete_task "Updated dotfiles"

## Update the CLI
if [[ -n "${args["--cli"]}" ]]; then
	update_cli() {
		script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)/dotfiles"
		if [[ ! -f "${script_dir}" ]]; then
			echo "Could not find '${script_dir}'"
			exit 1
		fi

		updated_script_dir=$(realpath "$(chezmoi source-path)/../scripts/unix/dotfiles")
		if [[ ! -f "${updated_script_dir}" ]]; then
			echo "Could not find '${updated_script_dir}'"
			exit 1
		fi

		## Check if the CLI is already up to date
		if [[ "${script_dir}" == "${updated_script_dir}" ]]; then
			echo "The CLI is already up to date"
			exit 2
		fi

		cp -f "${updated_script_dir}" "${script_dir}"
	}

	show_spinner "update_cli" "Updating CLI" "Updated CLI"
fi

## Update Neovim related files
if [[ -n "${args["--nvim"]}" ]]; then
	## Update Neovim
	update_neovim() {
		bob update --all
	}
	show_spinner "update_neovim" "Updating Neovim" "Updated Neovim"

	## Update Lazy plugins and Mason packages
	update_neovim_plugins() {
		nvim --headless -c "Lazy! sync" +qa
	}
	show_spinner "update_neovim_plugins" "Updating Neovim plugins" "Updated Neovim plugins"

	update_mason_packages() {
		nvim --headless -c "lua vim.schedule(function() vim.api.nvim_create_autocmd('User', { pattern = 'MasonToolsUpdateCompleted', command = 'qa' }); require('mason-tool-installer').check_install(true) end)"
	}
	show_spinner "update_mason_packages" "Updating Mason packages" "Updated Mason packages"

	source_path=$(chezmoi source-path)
	## Sync lazy-lock.json file
	lazy_lock_path=$(find "${source_path}" -type f -name "*lazy-lock.json" -print -quit)
	sync_lazy_lock() {
		if [[ ! -f "${lazy_lock_path}" ]]; then
			echo "Could not find 'lazy-lock.json' file in '${source_path}'"
			exit 1
		fi
		config_path="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
		updated_lazy_lock_path=$(find "${config_path}" -type f -name "*lazy-lock.json" -print -quit)
		if [[ ! -f "${updated_lazy_lock_path}" ]]; then
			echo "Could not find 'lazy-lock.json' file in '${config_path}'"
			exit 1
		fi
		cp -f "${updated_lazy_lock_path}" "${lazy_lock_path}"
	}
	show_spinner "sync_lazy_lock" "Syncing 'lazy-lock.json' file" "Synced 'lazy-lock.json' file"

	## Commit the updated 'lazy-lock.json' file
	commit_lazy_lock() {
		current_path=$(pwd)
		cd "$(realpath "$(chezmoi source-path)/..")" || exit 1
		# Check if there are any changes
		if git diff --quiet "${lazy_lock_path}"; then
			echo "No changes in 'lazy-lock.json' file"
			exit 2
		fi
		git add "${lazy_lock_path}"
		git commit "${lazy_lock_path}" -m "chore(nvim): update lazy-lock.json"
		cd "${current_path}" || exit 1
	}
	show_spinner "commit_lazy_lock" "Committing 'lazy-lock.json' file" "Committed 'lazy-lock.json' file"

	## Sync lazyvim.json file
	lazyvim_path=$(find "${source_path}" -type f -name "*lazyvim.json" -print -quit)
	sync_lazyvim() {
		if [[ ! -f "${lazyvim_path}" ]]; then
			echo "Could not find 'lazyvim.json' file in '${source_path}'"
			exit 1
		fi
		config_path="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
		updated_lazyvim_path=$(find "${config_path}" -type f -name "*lazyvim.json" -print -quit)
		if [[ ! -f "${updated_lazyvim_path}" ]]; then
			echo "Could not find 'lazyvim.json' file in '${config_path}'"
			exit 1
		fi
		cp -f "${updated_lazyvim_path}" "${lazyvim_path}"
	}
	show_spinner "sync_lazyvim" "Syncing 'lazyvim.json' file" "Synced 'lazyvim.json' file"

	## Commit the updated 'lazyvim.json' file
	commit_lazyvim() {
		current_path=$(pwd)
		cd "$(realpath "$(chezmoi source-path)/..")" || exit 1
		# Check if there are any changes
		if git diff --quiet "${lazyvim_path}"; then
			echo "No changes in 'lazyvim.json' file"
			exit 2
		fi
		git add "${lazyvim_path}"
		git commit "${lazyvim_path}" -m "chore(nvim): update lazyvim.json"
		cd "${current_path}" || exit 1
	}
	show_spinner "commit_lazyvim" "Committing 'lazyvim.json' file" "Committed 'lazyvim.json' file"
fi
