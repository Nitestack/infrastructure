import re

# File paths and markers
BINDINGS_FILE = "home/private_dot_config/exact_hypr/exact_hyprland/bindings.conf"
README_FILE = "README.md"
START_MARKER = "### Hyprland Bindings"
END_MARKER = "#### Binding Flags"


def preprocess_variables(file_path):
    """
    Preprocess variables from a configuration file.

    Args:
    - file_path (str): Path to the configuration file.

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


def parse_bindings(file_path, variables):
    """
    Parse bindings from a configuration file using predefined patterns.

    Args:
    - file_path (str): Path to the bindings configuration file.
    - variables (dict): Dictionary of variables for variable substitution.

    Returns:
    - bindings (list): List of parsed bindings as dictionaries.
    """
    bindings = []

    with open(file_path, "r") as file:
        for line in file:
            # Skip lines that do not start with 'bind'
            if not line.startswith("bind"):
                continue

            # Strip leading/trailing whitespace and comments
            line = line.strip()

            # Replace variables
            for var_name, var_value in variables.items():
                line = line.replace(f"${var_name}", var_value)

            # Debug: print processed line
            print(f"Processed line: {line}")

            # Remove comment at end of line if present
            line = re.sub(r"\s*#.*$", "", line)

            # Debug: print line after removing comments
            print(f"Line after comment removal: {line}")

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
            key = ""
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
                key = bind_with_description.group(3).strip()
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
                key = bind_match.group(3).strip()
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
                        "key": key,
                        "description": description,
                        "dispatcher": dispatcher,
                        "params": params,
                    }
                )

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
    }

    table_content = "| Modifiers | Key | Description | Flags |\n"
    table_content += "| --- | --- | --- | --- |\n"

    def change_mod_label(mod):
        mod = mod.capitalize() if mod.isalpha() else mod

        if mod == "Super":
            mod = "Win"

        return mod

    for binding in bindings:
        # Mods
        modifiers = (
            " + ".join(map(change_mod_label, binding["mods"]))
            if len(binding["mods"]) > 0
            else "-"
        )
        # Key
        key = re.sub(r"XF86([a-zA-Z0-9]+)", r"\1 Button", binding["key"])
        if binding["key"] in key_labels:
            key = key_labels[binding["key"]]
        key = key.capitalize() if key.isalpha() else key

        # Optional description
        description = binding["description"] if binding["description"] else "-"

        # Flags
        flags = "`" + "`, `".join(binding["flags"]) + "`" if binding["flags"] else "-"

        table_content += f"| {modifiers} | {key} | {description} | {flags} |\n"

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
    print("Script started")

    # Preprocess variables from the bindings file
    variables = preprocess_variables(BINDINGS_FILE)
    print(f"Variables: {variables}")

    # Parse bindings using preprocessed variables
    bindings = parse_bindings(BINDINGS_FILE, variables)
    print(f"Bindings: {bindings}")

    # Generate markdown table from parsed bindings
    table_content = generate_table(bindings)
    print(f"Table content:\n{table_content}")

    # Update the README file with the generated table content
    update_readme(README_FILE, START_MARKER, END_MARKER, table_content)
    print("README.md updated")

    # Debug: Print the completion
    print("Script completed")
