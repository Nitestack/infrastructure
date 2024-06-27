import re

BINDINGS_FILE = 'home/private_dot_config/exact_hypr/exact_hyprland/bindings.conf'
README_FILE = 'README.md'
START_MARKER = '### Hyprland Bindings'
END_MARKER = '## 🙌 Credits'

def parse_bindings(file_path):
    bindings = []
    with open(file_path, 'r') as file:
        for line in file:
            # Strip leading/trailing whitespace and comments
            line = line.strip()
            if not line or line.startswith('#'):
                continue  # Skip empty lines and comments

            # Remove comment at end of line if present
            line = re.sub(r'\s*#.*$', '', line)

            # Skip lines that do not start with 'bind'
            if not line.startswith('bind'):
                continue

            # Extract flags immediately after 'bind'
            flags_match = re.match(r'^bind\s*([a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*)$', line)
            if flags_match:
                flags = list(flags_match.group(1))
                mods = flags_match.group(2).strip()
                key = flags_match.group(3).strip()

                # Split dispatcher and params
                dispatcher_and_params = flags_match.group(4).strip().split(',', 1)
                dispatcher = dispatcher_and_params[0].strip()
                params = dispatcher_and_params[1].strip() if len(dispatcher_and_params) > 1 else ''

                # Determine description based on the presence of 'd' flag
                description = ''
                if 'd' in mods:
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
    table_content = "| Modifiers | Key | Description | Dispatcher | Params | Flags |\n"
    table_content += "| --- | --- | --- | --- | --- | --- |\n"

    for binding in bindings:
        modifiers = binding['mods']
        key = binding['key']
        description = binding['description'] if binding['description'] else '-'
        dispatcher = binding['dispatcher']
        params = binding['params'] if binding['params'] else '-'
        flags = ' '.join(binding['flags']) if binding['flags'] else '-'

        table_content += f"| {modifiers} | {key} | {description} | {dispatcher} | {params} | {flags} |\n"

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

    print("Updated README content:")
    print(updated_readme)  # Print the updated content to verify

    # Write the updated content back to README.md
    with open(readme_file, 'w') as file:
        file.write(updated_readme)

    print(f"README.md successfully updated with bindings table between {start_marker} and {end_marker}")

if __name__ == "__main__":
    bindings = parse_bindings(BINDINGS_FILE)
    table_content = generate_table(bindings)
    update_readme(README_FILE, START_MARKER, END_MARKER, table_content)
