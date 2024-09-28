# shellcheck shell=bash
# ╭──────────────────────────────────────────────────────────╮
# │ BASH LIBRARY                                             │
# ╰──────────────────────────────────────────────────────────╯

set -uo pipefail

# ── Log ───────────────────────────────────────────────────────────────
_log_header() {
	gum format -- "# $1"
}

_log() {
	gum log -s "$@"
}

_spin() {
	title=$1
	shift

	gum spin --show-error --spinner points --title "${title}" "$@"
}

# ── Utils ─────────────────────────────────────────────────────────────

# Function to set an option with sudo access
# Usage: _set_option_with_sudo <option_name> <option_value> <config_file> <optional: quote_value> <optional: add_whitespace>
_set_option_with_sudo() {
	local option_name="$1"
	local option_value="$2"
	local config_file="$3"
	local quote_value="${4:-false}"
	local add_whitespace="${5:-false}"

	# Quote the option value if the quote_value flag is set to true
	if [[ "${quote_value}" = true ]]; then
		option_value="\"${option_value}\""
	fi

	# Define the whitespace around the equal sign if add_whitespace is set to true
	local whitespace=""
	if [[ "${add_whitespace}" = true ]]; then
		whitespace=" "
	fi

	# Regular expression patterns to match lines with optional whitespace around the equal sign
	local pattern="^\s*${option_name}\s*=\s*${option_value}\s*$"
	local commented_pattern="^\s*#\s*${option_name}\s*=\s*${option_value}\s*$"
	local commented_any_value_pattern="^\s*#\s*${option_name}\s*=\s*.*$"
	local any_value_pattern="^\s*${option_name}\s*=\s*.*$"

	# Check if the exact option is already set in the config file
	if grep -Eq "${pattern}" "${config_file}"; then
		return
	fi

	# Check if the option is commented out with the exact value
	if grep -Eq "${commented_pattern}" "${config_file}"; then
		sudo sed -i "s|${commented_pattern}|${option_name}${whitespace}=${whitespace}${option_value}|" "${config_file}"
	else
		# Check if the option is commented out with any value
		if grep -Eq "${commented_any_value_pattern}" "${config_file}"; then
			sudo sed -i "s|${commented_any_value_pattern}|${option_name}${whitespace}=${whitespace}${option_value}|" "${config_file}"
		else
			# Check if the option is set with any value
			if grep -Eq "${any_value_pattern}" "${config_file}"; then
				sudo sed -i "s|${any_value_pattern}|${option_name}${whitespace}=${whitespace}${option_value}|" "${config_file}"
			else
				# If the option is not present at all, add it to the end of the config file
				echo "${option_name}${whitespace}=${whitespace}${option_value}" | sudo tee -a "${config_file}"
			fi
		fi
	fi
}

# Function to enable a flag with sudo access (option without a value)
# Usage: _enable_flag_with_sudo <flag_name> <config_file>
_enable_flag_with_sudo() {
	local flag_name="$1"
	local config_file="$2"

	if grep -q "^${flag_name}$" "${config_file}"; then
		return
	fi

	if grep -q "^#${flag_name}$" "${config_file}"; then
		sudo sed -i "s|^#${flag_name}$|${flag_name}|" "${config_file}"
		sudo sed -i "s|^#${flag_name}=.*|${flag_name}|" "${config_file}"
	else
		echo "${flag_name}" | sudo tee -a "${config_file}"
	fi
}

# Function to write content to a file with sudo access
# Usage: _write_file_with_sudo <file_path> <content>
_write_file_with_sudo() {
	local file_path="$1"
	local content="$2"

	sudo -v

	_spin "Writing to ${file_path}" -- echo "${content}" | sudo tee "${file_path}" >/dev/null
}
