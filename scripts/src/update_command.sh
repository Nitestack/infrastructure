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

if [[ -n "${args["--cli"]}" ]]; then
	script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)/dotfiles"

	updated_script_dir=$(realpath "$(eval echo "$(chezmoi source-path)")/../scripts/dotfiles")

	command_exec cp -f "${updated_script_dir}" "${script_dir}"

	log_success "Updated the CLI to the latest version"
fi
