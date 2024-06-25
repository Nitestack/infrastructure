# shellcheck shell=bash
# ╭──────────────────────────────────────────────────────────╮
# │ BASH LIBRARY                                             │
# ╰──────────────────────────────────────────────────────────╯

set -uo pipefail

echo

# ── Log ───────────────────────────────────────────────────────────────
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
# Usage: _set_option_with_sudo <option_name> <option_value> <config_file>
_set_option_with_sudo() {
	local option_name="$1"
	local option_value="$2"
	local config_file="$3"

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
		sudo sed -i "s|${commented_pattern}|${option_name}=${option_value}|" "${config_file}"
	else
		# Check if the option is commented out with any value
		if grep -Eq "${commented_any_value_pattern}" "${config_file}"; then
			sudo sed -i "s|${commented_any_value_pattern}|${option_name}=${option_value}|" "${config_file}"
		else
			# Check if the option is set with any value
			if grep -Eq "${any_value_pattern}" "${config_file}"; then
				sudo sed -i "s|${any_value_pattern}|${option_name}=${option_value}|" "${config_file}"
			else
				# If the option is not present at all, add it to the end of the config file
				echo "${option_name}=${option_value}" | sudo tee -a "${config_file}"
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

# ── Arch Linux ────────────────────────────────────────────────────────
# {{ if eq .osid "linux-arch" }}

# Function to install packages using pacman
# Usage: _install_packages_pacman <package1> [<package2> ...]
_install_packages_pacman() {
	toInstall=()

	for pkg; do
		if pacman -Q "${pkg}" &>/dev/null; then
			_log -l warn --prefix "pacman" "${pkg} is already installed"
			continue
		fi
		toInstall+=("${pkg}")
	done

	if [[ "${toInstall[*]}" == "" ]]; then
		return
	fi

	sudo pacman --needed --noconfirm -S "${toInstall[@]}"
}

# Function to install packages using paru
# Usage: _install_packages_paru <package1> [<package2> ...]
_install_packages_paru() {
	toInstall=()

	for pkg; do
		if paru -Q "${pkg}" &>/dev/null; then
			_log -l warn --prefix "paru" "${pkg} is already installed"
			continue
		fi
		toInstall+=("${pkg}")
	done

	if [[ "${toInstall[*]}" == "" ]]; then
		return
	fi

	paru --needed -S "${toInstall[@]}"
}

# Function to ensure a system service is enabled with sudo
# Usage: _enable_system_service <service_name> [<pre_exec_function>]
_enable_system_service() {
	local service_name="$1"
	local pre_exec_function="${2:-}"

	_log -l info --prefix "systemd" "Enabling ${service_name} service"

	if systemctl is-enabled --quiet "${service_name}"; then
		_log -l warn --prefix "systemd" "Service ${service_name} is already enabled"
	else
		[[ -n ${pre_exec_function} ]] && ${pre_exec_function}

		sudo -v

		# Enable service
		_spin "Enabling ${service_name} service" -- sudo systemctl enable "${service_name}"
		# Start service
		_spin "Starting ${service_name} service" -- sudo systemctl start "${service_name}"

		_log -l info --prefix "systemd" "Enabled ${service_name} service"
	fi
}

# Function to ensure a system service is enabled for the current user
# Usage: _enable_user_service <service_name> [<pre_exec_function>]
_enable_user_service() {
	local service_name="$1"
	local pre_exec_function="${2:-}"

	_log -l info --prefix "systemd" "Enabling ${service_name} service for the current user"

	if systemctl --user is-enabled --quiet "${service_name}"; then
		_log -l warn --prefix "systemd" "Service ${service_name} is already enabled for the current user"
	else
		[[ -n ${pre_exec_function} ]] && ${pre_exec_function}

		# Enable service for the current user
		_spin "Enabling ${service_name} service for the current user" -- systemctl --user enable "${service_name}"
		# Start service for the current user
		_spin "Starting ${service_name} service for the current user" -- systemctl --user start "${service_name}"

		_log -l info --prefix "systemd" "Enabled ${service_name} service for the current user"
	fi
}

# {{ end }}
