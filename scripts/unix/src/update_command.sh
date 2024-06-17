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
