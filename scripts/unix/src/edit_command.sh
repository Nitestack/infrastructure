if [[ "${#args[@]}" -eq 0 ]]; then
	cd ~/.dotfiles || exit 1
	command -v nvim >/dev/null && nvim
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
