import re

BINDINGS_FILE = "home/private_dot_config/exact_hypr/exact_hyprland/bindings.conf"
README_FILE = "README.md"
START_MARKER = "### Hyprland Bindings"
END_MARKER = "#### Binding Flags"


def preprocess_variables(file_path):
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

            # Remove comment at end of line if present
            line = re.sub(r"\s*#.*$", "", line)

            # A binding without a description
            # bind<flag[]> = <mod[]>, <key>, <dispatcher>, [params]
            bind_match = re.match(
                r"^bind([a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)(?:\s*,\s*(.*?))?\s*$",
                line,
            )
            # A binding with a description
            # bindd<flag[]> = <mod[]>, <key>, <description>, <dispatcher>, [params]
            bind_with_description = re.match(
                r"^bind([a-z]*d[a-z]*)\s*=\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)\s*,\s*(.*?)(?:\s*,\s*(.*?))?\s*$",
                line,
            )
            flags = []
            mods = []
            key = ""
            dispatcher = ""
            params = ""
            description = ""

            if bind_with_description:
                flags = list(bind_with_description.group(1))
                mods = bind_with_description.group(2).split(" ")
                key = bind_with_description.group(3)
                description = bind_with_description.group(4)
                dispatcher = bind_with_description.group(5)
                params = (
                    bind_with_description.group(6)
                    if bind_with_description.group(6)
                    else ""
                )
                flags.remove("d")
            elif bind_match:
                flags = list(bind_match.group(1))
                mods = bind_match.group(2).split(" ")
                key = bind_match.group(3)
                dispatcher = bind_match.group(4)
                params = bind_match.group(5) if bind_match.group(5) else ""

            if bind_match or bind_with_description:
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
    table_content = "| Modifiers | Key | Dispatcher | Params | Flags | Description |\n"
    table_content += "| --- | --- | --- | --- | --- | --- |\n"

    for binding in bindings:
        modifiers = " + ".join(binding["mods"])
        key = binding["key"]
        description = binding["description"] if binding["description"] else "-"
        dispatcher = binding["dispatcher"]
        params = binding["params"] if binding["params"] else "-"
        flags = "`" + "`, `".join(binding["flags"]) + "`" if binding["flags"] else "-"

        table_content += f"| {modifiers} | {key} | {dispatcher} | `{params}` | {flags} | {description} |\n"

    return table_content.strip()


def update_readme(readme_file, start_marker, end_marker, table_content):
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
    variables = preprocess_variables(BINDINGS_FILE)
    bindings = parse_bindings(BINDINGS_FILE, variables)
    table_content = generate_table(bindings)
    update_readme(README_FILE, START_MARKER, END_MARKER, table_content)
