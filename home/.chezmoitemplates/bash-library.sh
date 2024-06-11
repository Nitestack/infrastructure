# shellcheck shell=bash

set -uo pipefail

log_color() {
	local color_code="$1"
	shift

	printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}
log_red() {
	log_color "0;31" "$@"
}
log_blue() {
	log_color "0;34" "$@"
}
log_green() {
	log_color "0;32" "$@"
}
log_info() {
	echo "" "$@"
}
start_task() {
	echo "󰪥" "$@"
}
complete_task() {
	log_green "" "$@"
}

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
			printf "\r%s %s" "${spinner_frames[i]}" "${start_message}"
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
	printf "\r%s %s" "${spinner_frames[${last_index}]}" "${start_message}"

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

pacman_ensure_installed() {
	local package_name="$1"
	shift

	install_with_pacman() {
		if pacman -Qi "${package_name}" &>/dev/null; then
			echo "${package_name}"
			exit 2
		fi

		sudo pacman -S --needed --noconfirm "${package_name}"
	}

	show_spinner "install_with_pacman" "${package_name}" "${package_name}"
}

yay_ensure_installed() {
	local package_name="$1"
	shift

	install_with_yay() {
		if yay -Qi "${package_name}" &>/dev/null; then
			echo "${package_name}"
			exit 2
		fi

		yay -S --needed --noconfirm "${package_name}"
	}

	show_spinner "install_with_yay" "${package_name}" "${package_name}"
}

brew_ensure_formula_installed() {
	local formula="$1"
	shift

	install_formula_with_brew() {
		if brew list "${formula}" &>/dev/null; then
			echo "${formula}"
			exit 2
		fi

		brew install "${formula}"
	}

	show_spinner "install_formula_with_brew" "${formula}" "${formula}"
}

brew_ensure_cask_installed() {
	local cask="$1"
	shift

	install_cask_with_brew() {
		if brew list --cask "${cask}" &>/dev/null; then
			echo "${cask}"
			exit 2
		fi

		brew install --cask "${cask}"
	}

	show_spinner "install_cask_with_brew" "${cask}" "${cask}"
}
