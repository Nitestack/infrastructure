show_spinner() {
	local task="$1"
	local start_message="$2"
	local completion_message="$3"
	local error_message="${4:-An unexpected error occurred}"

	local spinner_frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

	display_spinner() {
		local pid=$!
		local i=0
		tput civis # Hide cursor

		while kill -0 "${pid}" 2>/dev/null; do
			printf "\r\e[33m%s %s\e[0m" "${spinner_frames[i]}" "${start_message}" # Yellow color
			i=$(((i + 1) % ${#spinner_frames[@]}))
			sleep 0.1
		done

		tput cnorm # Show cursor
	}

	# Run the task in the background, redirect stdout and stderr to separate temporary files
	local temp_out_log=$(mktemp)
	local temp_err_log=$(mktemp)
	(${task} >"${temp_out_log}" 2>"${temp_err_log}") &

	display_spinner "${start_message}"

	# Wait for the task to complete
	wait $!
	local exit_code=$?

	# Print last frame of the spinner
	last_index=$((${#spinner_frames[@]} - 1))
	printf "\r\e[33m%s %s\e[0m" "${spinner_frames[${last_index}]}" "${start_message}" # Yellow color

	# Get the last echo message from the output log file
	local last_echo=$(tail -n 1 "${temp_out_log}")

	# Remove the last line of the output log file, if the exit code is greater than 1
	if [[ ${exit_code} -gt 1 ]]; then
		sed -i '$ d' "${temp_out_log}"
	fi

	# Display stdout logs if they are not empty
	if [[ -s "${temp_out_log}" ]]; then
		echo
		cat "${temp_out_log}"
	fi

	# Display stderr logs if they are not empty
	if [[ -s "${temp_err_log}" ]]; then
		echo
		cat "${temp_err_log}" | while IFS= read -r line; do echo -e "\033[31m${line}\033[0m"; done
	fi

	# Clear the line before displaying the final message
	printf "\r\033[K"

	# Display completion or error message based on exit code
	if [[ ${exit_code} -eq 0 ]]; then
		printf "\r\e[32m%s %s\e[0m\n" "󰗠" "${completion_message}" # Green color
	elif [[ ${exit_code} -eq 1 ]]; then
		printf "\r\e[31m%s %s\e[0m\n" "" "${error_message}" # Red color
	else
		printf "\r%s %s\n" "" "${last_echo}"
	fi

	# Clean up
	rm "${temp_out_log}" "${temp_err_log}"
}
