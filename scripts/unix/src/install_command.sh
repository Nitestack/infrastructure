log_task "Installing dotfiles"

## Set arguments
sourceDir=$(expand_tilde "${args[sourceDir]}")

set -- --source="${sourceDir}" --verbose=false

if [[ -n "${args["--one-shot"]}" ]]; then
	set -- "$@" --one-shot
else
	set -- "$@" --apply
fi

command_exec chezmoi init "$@"

log_success "Installed dotfiles"
