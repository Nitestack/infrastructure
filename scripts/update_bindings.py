import re

# File paths and markers
HYPRLAND_BINDINGS_FILE = (
    "home/private_dot_config/exact_hypr/exact_hyprland/bindings.conf"
)
KOMOREBI_AHK_CONFIG_FILE = "home/private_AppData/Roaming/exact_komorebi/komorebi.ahk"
README_FILE = "README.md"
START_MARKER = "### Bindings"
END_MARKER = "#### OS Compatibility"


def preprocess_hyprland_variables(file_path):
    """
    Preprocess variables from a Hyprland configuration file.

    Args:
    - file_path (str): Path to the Hyprland configuration file.

    Returns:
    - variables (dict): Dictionary of parsed variables.
    """
    variables = {}
    with open(file_path, "r") as file:
        for line in file:
            # Remove comments at end of line if present
            line = re.sub(r"\s*#.*$", "", line)
            line = line.strip()
            if line.startswith("$"):
                var_match = re.match(r"^\$([^\s=]+)\s*=\s*(.*?)$", line)
                if var_match:
                    var_name = var_match.group(1)
                    var_value = var_match.group(2).strip()
                    variables[var_name] = var_value
    return variables


def parse_bindings(hyprland_config_path, variables, ahk_config_path):
    """
    Parse bindings from a configuration file using predefined patterns.

    Args:
    - hyprland_config_path (str): Path to the bindings configuration file.
    - variables (dict): Dictionary of variables for variable substitution.
    - ahk_config_path (str): Path to the AutoHotKey configuration file (Windows).

    Returns:
    - bindings (list): List of parsed bindings as dictionaries.
    """
    bindings = []

    win_bindings = [
        {"mods": ["ALT"], "key": "space"},
        {"mods": ["SUPER"], "key": "V"},
        {"mods": [], "key": "XF86PowerOff"},
        {"mods": [], "key": "Print"},
        {"mods": ["SUPER"], "key": "Print"},
        {"mods": ["SUPER", "ALT"], "key": "Print"},
        {"mods": ["SUPER"], "key": "E"},
        {"mods": ["CTRL", "SHIFT"], "key": "Escape"},
        {"mods": [], "key": "XF86AudioLowerVolume"},
        {"mods": [], "key": "XF86AudioRaiseVolume"},
        {"mods": [], "key": "XF86AudioMute"},
        {"mods": [], "key": "XF86AudioMicMute"},
        {"mods": [], "key": "XF86AudioPlay"},
        {"mods": [], "key": "XF86AudioPause"},
        {"mods": [], "key": "XF86AudioNext"},
        {"mods": [], "key": "XF86AudioPrev"},
        {"mods": [], "key": "XF86MonBrightnessDown"},
        {"mods": [], "key": "XF86MonBrightnessUp"},
    ]

    ahk_mods = {"#": "SUPER", "^": "CTRL", "+": "SHIFT", "!": "ALT"}
    ahk_characters = {
        "\\": "Backslash",
        "WheelUp": "mouse_up",
        "WheelDown": "mouse_down",
    }

    with open(hyprland_config_path, "r") as file:
        for line in file:
            # Strip leading/trailing whitespace and comments
            line = line.strip()

            # Skip lines that do not start with 'bind'
            if not line.startswith("bind"):
                continue

            # Replace variables
            for var_name, var_value in variables.items():
                line = line.replace(f"${var_name}", var_value)

            # Remove comment at end of line if present
            line = re.sub(r"\s*#.*$", "", line)

            # Patterns for different binding types
            bind_match = re.match(
                r"^bind([a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)(?:\s*,\s*(.*?))?\s*$",
                line,
            )
            bind_with_description = re.match(
                r"^bind([a-z]*d[a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)(?:\s*,\s*(.*?))?\s*$",
                line,
            )

            # Initialize variables for parsing
            flags = []
            mods = []
            unresolved_key = ""
            dispatcher = ""
            params = ""
            description = ""

            # Parse based on matched pattern
            if bind_with_description:
                flags = list(bind_with_description.group(1).strip())
                mods = (
                    bind_with_description.group(2).strip().split(" ")
                    if bind_with_description.group(2).strip()
                    else []
                )
                unresolved_key = bind_with_description.group(3).strip()
                description = bind_with_description.group(4).strip()
                dispatcher = bind_with_description.group(5).strip()
                params = (
                    bind_with_description.group(6).strip()
                    if bind_with_description.group(6)
                    else ""
                )
                flags.remove("d")
            elif bind_match:
                flags = list(bind_match.group(1).strip())
                mods = (
                    bind_match.group(2).strip().split(" ")
                    if bind_match.group(2).strip()
                    else []
                )
                unresolved_key = bind_match.group(3).strip()
                dispatcher = bind_match.group(4).strip()
                params = bind_match.group(5).strip() if bind_match.group(5) else ""

            # If a valid binding was found, add to bindings list
            if bind_match or bind_with_description:
                if "m" in flags:
                    flags.remove("m")
                bindings.append(
                    {
                        "flags": flags,
                        "mods": mods,
                        "key": unresolved_key,
                        "description": description,
                        "dispatcher": dispatcher,
                        "params": params,
                    }
                )

    with open(ahk_config_path, "r") as file:
        beginning = False
        for line in file:
            # Strip leading/trailing whitespace and comments
            line = line.strip()

            # Don't start until we find the `Komorebic` function
            if line.startswith("Komorebic"):
                beginning = True
                continue
            if not beginning or line == "":
                continue

            if line[0] not in ahk_mods.keys():
                continue

            mods = []
            key = ""

            keys = re.findall(r"\w+|\W", line.split("::")[0])

            for unresolved_key in keys:
                if unresolved_key in ahk_mods.keys():
                    mods.append(ahk_mods[unresolved_key])
                elif unresolved_key in ahk_characters.keys():
                    key = ahk_characters[unresolved_key]
                else:
                    key = unresolved_key.upper() or ""

            if key and mods:
                win_bindings.append(
                    {
                        "mods": mods,
                        "key": key,
                    }
                )

    for win_binding in win_bindings:
        for binding in bindings:
            if (
                set(map(lambda mod: mod.lower(), binding["mods"]))
                == set(map(lambda mod: mod.lower(), win_binding["mods"]))
                and binding["key"].lower() == win_binding["key"].lower()
            ):
                binding["has_win"] = True

    return bindings


def generate_table(bindings):
    """
    Generate a markdown table from parsed bindings.

    Args:
    - bindings (list): List of bindings as dictionaries.

    Returns:
    - table_content (str): Markdown formatted table content.
    """
    key_labels = {
        "mouse:272": "Left Mouse Button",
        "mouse:273": "Right Mouse Button",
        "mouse_up": "Mouse Wheel Up",
        "mouse_down": "Mouse Wheel Down",
        "left": "←",
        "right": "→",
        "up": "↑",
        "down": "↓",
    }

    table_content = "| Modifiers | Key | Description | OS | Flags |\n"
    table_content += "| --- | --- | --- | --- | --- |\n"

    def change_mod_label(mod):
        if mod.lower() in key_labels.keys():
            mod = key_labels[mod.lower()]
        mod = (
            mod.capitalize() if mod.isalpha() and mod.lower() not in key_labels else mod
        )

        if mod == "Super":
            mod = "Win"

        return mod

    for binding in bindings:
        # Mods
        modifiers = (
            "<kbd>"
            + ("</kbd> + <kbd>".join(map(change_mod_label, binding["mods"])))
            + "</kbd>"
            if len(binding["mods"]) > 0
            else "-"
        )
        # Key
        key = re.sub(r"XF86([a-zA-Z0-9]+)", r"\1 Button", binding["key"])
        if binding["key"].lower() in key_labels.keys():
            key = key_labels[binding["key"].lower()]
        key = (
            key.capitalize()
            if key.isalpha() and binding["key"].lower() not in key_labels
            else key
        )

        # Optional description
        description = binding["description"] if binding["description"] else "-"

        # Flags
        flags = "`" + "`, `".join(binding["flags"]) + "`" if binding["flags"] else "-"

        table_content += f"| {modifiers} | <kbd>{key}</kbd> | {description} | `L`{", `W`" if ("has_win" in binding and binding["has_win"] or False) else ""} | {flags} |\n"

    return table_content.strip()


def update_readme(readme_file, start_marker, end_marker, table_content):
    """
    Update the README file with the generated table content.

    Args:
    - readme_file (str): Path to the README file.
    - start_marker (str): Start marker in README to begin updating from.
    - end_marker (str): End marker in README to stop updating at.
    - table_content (str): Markdown formatted table content.
    """
    updated_readme = ""
    in_bindings_section = False

    with open(readme_file, "r") as file:
        readme_lines = file.readlines()

    for line in readme_lines:
        if line.strip() == start_marker:
            in_bindings_section = True
            updated_readme += line
            updated_readme += "\n"
            updated_readme += table_content + "\n\n"
        elif line.strip() == end_marker:
            in_bindings_section = False
            updated_readme += line
        elif not in_bindings_section:
            updated_readme += line

    with open(readme_file, "w") as file:
        file.write(updated_readme)


if __name__ == "__main__":
    # Debug: Print the starting point
    print("Running script...")

    # Preprocess variables from the bindings file
    print("Preprocessing variables...")
    variables = preprocess_hyprland_variables(HYPRLAND_BINDINGS_FILE)
    print(f"Variables: {variables}")

    # Parse bindings using preprocessed variables
    print("Parsing bindings...")
    bindings = parse_bindings(
        HYPRLAND_BINDINGS_FILE, variables, KOMOREBI_AHK_CONFIG_FILE
    )
    print(f"Bindings: {bindings}")

    # Generate markdown table from parsed bindings
    print("Generating table...")
    table_content = generate_table(bindings)
    print(f"Table content:\n{table_content}")

    # Update the README file with the generated table content
    print("Updating README.md...")
    update_readme(README_FILE, START_MARKER, END_MARKER, table_content)
    print("README.md updated")

    # Debug: Print the completion
    print("Script completed")
