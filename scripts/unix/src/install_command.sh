start_task "Installing dotfiles"

## Set arguments
sourceDir=$(expand_tilde "${args[sourceDir]}")

set -- --source="${sourceDir}" --verbose=false

if [[ -n "${args["--one-shot"]}" ]]; then
	set -- "$@" --one-shot
else
	set -- "$@" --apply
fi

chezmoi init "$@"

complete_task "Installed dotfiles"
