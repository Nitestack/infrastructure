#!/usr/bin/env nu

def get_app_name [class_name: string] {
    let xdg_dirs = if ($env.XDG_DATA_DIRS? | is-not-empty) {
        $env.XDG_DATA_DIRS | split row ':'
    } else {
        ["/run/current-system/sw/share" "/usr/share" "/usr/local/share"]
    }

    let user_data_dir = if ($env.XDG_DATA_HOME? | is-not-empty) {
        $env.XDG_DATA_HOME
    } else {
        $"($env.HOME)/.local/share"
    }
    let all_dirs = [$user_data_dir] ++ $xdg_dirs

    for data_dir in $all_dirs {
        let app_dir = $data_dir | path join "applications"

        if ($app_dir | path exists) {
            let desktop_pattern = $app_dir | path join "*.desktop"
            let desktop_files = try { glob $desktop_pattern } catch { continue }

            for desktop_file in $desktop_files {
                if ($desktop_file | path exists) {
                    let content = try { open $desktop_file } catch { continue }

                    let matches = (
                        (($desktop_file | path basename | str replace ".desktop" "") == ($class_name | str downcase)) or
                        ($content | str contains $"StartupWMClass=($class_name)") or
                        ($content | lines | any {|line|
                            ($line | str starts-with "Exec=") and ($line | str contains $class_name)
                        })
                    )

                    if $matches {
                        let name_line = $content | lines | where ($it | str starts-with "Name=") | first
                        if ($name_line | is-not-empty) {
                            return ($name_line | str replace "Name=" "")
                        }
                    }
                }
            }
        }
    }

    return $class_name
}

def output_json [app_name: string] {
    let json_output = {
        text: $app_name,
    }

    print ($json_output | to json --raw)
}

def get_monitor_active_workspace [monitor_name: string] {
    try {
        let monitors = hyprctl monitors -j | from json
        let monitor = $monitors | where name == $monitor_name | first
        return $monitor.activeWorkspace.id
    } catch {
        return (-1);
    }
}

def get_window_workspace [window_address: string] {
    try {
        let clients = hyprctl clients -j | from json
        let window = $clients | where address == $window_address | first
        return $window.workspace.id
    } catch {
        return (-1);
    }
}

def get_active_window_for_monitor [monitor_name: string] {
    try {
        let monitor = hyprctl monitors -j | from json | where name == $monitor_name | first

        let workspace = hyprctl workspaces -j | from json | where id == $monitor.activeWorkspace.id | first

        if ($workspace.windows > 0) {
            let window_class = if ($workspace.lastwindow? | is-not-empty) {
                let clients = hyprctl clients -j | from json
                let window = $clients | where address == $workspace.lastwindow | first
                $window.class
            } else {
                ""
            }

            if ($window_class | is-not-empty) {
                return (get_app_name $window_class)
            }
        }
        return "Desktop"
    } catch {
        return "Desktop"
    }
}

def handle_event [event: string] {
    let parts = $event | split row ">>"
    if ($parts | length) >= 2 {
        let event_type = $parts.0

        match $event_type {
            "activewindow" => {
                let event_data = $parts.1 | split row ","
                if ($event_data | length) >= 1 {
                    let window_class = $event_data.0
                    if ($window_class | is-not-empty) {
                        let active_window = try {
                            hyprctl activewindow -j | from json
                        } catch {
                            return
                        }

                        let window_workspace = $active_window.workspace.id
                        let our_workspace = get_monitor_active_workspace $env.WAYBAR_OUTPUT_NAME

                        if $window_workspace == $our_workspace {
                            let app_name = get_app_name $window_class
                            output_json $app_name
                        }
                    } else {
                        output_json "Desktop"
                    }
                }
            }
            "movewindow" => {
                let app_name = get_active_window_for_monitor $env.WAYBAR_OUTPUT_NAME
                output_json $app_name
            }
            _ => {}
        }
    }
}

def main [] {
    let app_name = get_active_window_for_monitor $env.WAYBAR_OUTPUT_NAME
    output_json $app_name

    socat -U - $"UNIX-CONNECT:($env.XDG_RUNTIME_DIR)/hypr/($env.HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock" | lines | each { |event| handle_event $event }
}
