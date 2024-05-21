if [[ "${#args[@]}" -eq 0 ]]; then
	cd "$(realpath "$(chezmoi source-path)/..")" || exit 1

	if [[ -n "${args[--neovide]}" ]] && command -v neovide &>/dev/null; then
		neovide
	elif command -v nvim &>/dev/null; then
		nvim
	fi
else
	set -- "${args[target]}"

	if [[ -n "${args[--apply]}" ]]; then
		set -- "$@" --apply
	fi
	if [[ -n "${args[--hardlink]}" ]]; then
		set -- "$@" --hardlink="${args[--hardlink]}"
	fi
	if [[ -n "${args[--watch]}" ]]; then
		set -- "$@" --watch
	fi

	chezmoi edit "$@"
fi
