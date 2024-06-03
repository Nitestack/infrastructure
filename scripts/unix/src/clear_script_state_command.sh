clear_script_state() {
	chezmoi state delete-bucket --bucket=entryState
	chezmoi state delete-bucket --bucket=scriptState
}

show_spinner "clear_script_state" "Clearing script state" "Cleared script state"
