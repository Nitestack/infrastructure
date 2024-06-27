import re

BINDINGS_FILE = 'home/private_dot_config/exact_hypr/exact_hyprland/bindings.conf'
README_FILE = 'README.md'
START_MARKER = '### Hyprland Bindings'
END_MARKER = '## 🙌 Credits'

# Function to preprocess variables
def preprocess_variables(file_path):
    variables = {}
    with open(file_path, 'r') as file:
        for line in file:
            # Remove comments at end of line if present
            line = re.sub(r'\s*#.*$', '', line)
            line = line.strip()
            if line.startswith('$'):
                var_match = re.match(r'^\$([^\s=]+)\s*=\s*(.*?)$', line)
                if var_match:
                    var_name = var_match.group(1)
                    var_value = var_match.group(2).strip()
                    variables[var_name] = var_value
    return variables

def parse_bindings(file_path, variables):
    bindings = []

    with open(file_path, 'r') as file:
        for line in file:
            # Skip lines that do not start with 'bind'
            if not line.startswith('bind'):
                continue

            # Strip leading/trailing whitespace and comments
            line = line.strip()

            # Replace variables
            for var_name, var_value in variables.items():
                line = line.replace(f'${var_name}', var_value)

            # Remove comment at end of line if present
            line = re.sub(r'\s*#.*$', '', line)

            # Extract flags immediately after 'bind'
            flags_match = re.match(r'^bind\s*([a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*)$', line)
            if flags_match:
                flags = list(flags_match.group(1))
                mods_str = flags_match.group(2).strip()
                key = flags_match.group(3).strip()

                # Capitalize first letter of key if it's a letter
                if key[0].isalpha():
                    key = key[0].upper() + key[1:]

                # Split mods and capitalize each part
                mods = [mod.capitalize() for mod in mods_str.split()]

                # Split dispatcher and params
                dispatcher_and_params = flags_match.group(4).strip().split(',', 1)
                dispatcher = dispatcher_and_params[0].strip()
                params = dispatcher_and_params[1].strip() if len(dispatcher_and_params) > 1 else ''

                # Determine description based on the presence of 'd' flag
                description = ''
                if 'd' in flags:
                    parts = dispatcher.split(',', 1)
                    if len(parts) > 1:
                        description = parts[0].strip()
                        dispatcher = parts[1].strip()

                bindings.append({
                    'flags': flags,
                    'mods': mods,
                    'key': key,
                    'description': description,
                    'dispatcher': dispatcher,
                    'params': params
                })

    return bindings


def generate_table(bindings):
    table_content = "| Modifiers | Key | Dispatcher | Params | Flags | Description |\n"
    table_content += "| --- | --- | --- | --- | --- | --- |\n"

    for binding in bindings:
        modifiers = ' + '.join(binding['mods'])  # Join multiple modifiers with space
        key = binding['key']
        description = binding['description'] if binding['description'] else '-'
        dispatcher = binding['dispatcher']
        params = binding['params'] if binding['params'] else '-'
        flags = '`' + '`, `'.join(binding['flags']) + '`' if binding['flags'] else '-'

        table_content += f"| {modifiers} | {key} | {dispatcher} | `{params}` | {flags} | {description} |\n"

    return table_content.strip()

def update_readme(readme_file, start_marker, end_marker, table_content):
    updated_readme = ""
    in_bindings_section = False

    with open(readme_file, 'r') as file:
        readme_lines = file.readlines()

    for line in readme_lines:
        if line.strip() == start_marker:
            in_bindings_section = True
            updated_readme += line
            updated_readme += "\n"  # Add a new line after start_marker
            updated_readme += table_content + "\n\n"
        elif line.strip() == end_marker:
            in_bindings_section = False
            updated_readme += line
        elif not in_bindings_section:
            updated_readme += line

    # Write the updated content back to README.md
    with open(readme_file, 'w') as file:
        file.write(updated_readme)

if __name__ == "__main__":
    variables = preprocess_variables(BINDINGS_FILE)
    bindings = parse_bindings(BINDINGS_FILE, variables)
    table_content = generate_table(bindings)
    update_readme(README_FILE, START_MARKER, END_MARKER, table_content)
