# ╭──────────────────────────────────────────────────────────╮
# │ Nushell Config                                           │
# ╰──────────────────────────────────────────────────────────╯

let host = {
  is-mac: (sys host | get name | $in == "Darwin")
  is-nixos: (sys host | get name | $in == "NixOS")
  is-windows: (sys host | get name | $in == "Windows")
  is-wsl: (sys host | get kernel_version | str contains "microsoft-standard-WSL2")
}

# ── Environment Variables ─────────────────────────────────────────────

$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.BAT_THEME = "Catppuccin Mocha"
$env.LS_COLORS = (vivid generate catppuccin-mocha)

# ── Configuration ─────────────────────────────────────────────────────

# History
$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5000000
$env.config.history.isolation = false

# Misc
$env.config.show_banner = false
$env.config.rm.always_trash = true

# Cmdline Editor
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "{{- ne .chezmoi.os "windows" | ternary "nvim" "code" -}}"
$env.config.cursor_shape.vi_normal = "block"
$env.config.cursor_shape.vi_insert = "line"

# Table
$env.config.table.mode = "compact"

# Completion
$env.config.completions.algorithm = "fuzzy"

# Colors
use nu-themes/catppuccin-mocha.nu

$env.config.highlight_resolved_externals = not $host.is-wsl
$env.config.color_config = (catppuccin-mocha)

# ── Aliases ───────────────────────────────────────────────────────────

# {{ if ne .chezmoi.os "windows" }} Ignore on Windows
alias "v" = nvim
alias "vimdiff" = nvim -d
# {{ end }}

# {{ if lookPath "proton-mail" }} Only for NixOS Desktop
alias "proton-mail" = XDG_SESSION_TYPE=x11 proton-mail
# {{ end }}

# {{ if and (eq .chezmoi.os "linux") (.chezmoi.kernel.osrelease | lower | contains "rpi") }}
def duc [] { docker compose pull; docker compose up -d; docker image prune }
# {{ end }}

alias "cp" = cp -iv
alias "mv" = mv -iv
alias "eza" = eza --icons always --git --group-directories-first --octal-permissions
alias "c" = clear
alias "l" = eza -gla
alias "lg" = lazygit
alias "ll" = eza -gl
alias "ls" = eza
alias "lt" = eza -T

# ── Initialization ────────────────────────────────────────────────────
# Nu Script Generation in `env.nu`

source $"($nu.default-config-dir)/.carapace.nu" # Carapace
source $"($nu.default-config-dir)/.oh-my-posh.nu" # Oh My Posh
source $"($nu.default-config-dir)/.zoxide.nu" # Zoxide

# {{ if lookPath "nix-your-shell" }} Only for Nix
source $"($nu.default-config-dir)/.nix-your-shell.nu" # Nix Your Shell
# {{ end }}

fastfetch
