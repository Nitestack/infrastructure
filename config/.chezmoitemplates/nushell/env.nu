# ╭──────────────────────────────────────────────────────────╮
# │ Nushell Environment                                      │
# ╰──────────────────────────────────────────────────────────╯

# {{ if ne .chezmoi.os "windows" }} Ignore on Windows
$env.path ++= ["~/.local/bin"]
# {{ end }}

# ── Initialization Script Generation ──────────────────────────────────
# Sourcing of Nu Script Generation in `config.nu`

# Carapace
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"
carapace _carapace nushell | save -f $"($nu.default-config-dir)/.carapace.nu"

# Oh My Posh
oh-my-posh init nu --config ~/.config/oh-my-posh/config.yml --print | save -f $"($nu.default-config-dir)/.oh-my-posh.nu"

# Zoxide
zoxide init nushell --cmd cd | save -f $"($nu.default-config-dir)/.zoxide.nu"

# Nix Your Shell
# {{ if lookPath "nix-your-shell" }} Only for Nix
nix-your-shell nu | save -f $"($nu.default-config-dir)/.nix-your-shell.nu"
# {{ end }}

# ── Libs ──────────────────────────────────────────────────────────────
const libs_dir = ($nu.default-config-dir | path join "lib")
$env.NU_LIB_DIRS ++= [
  $libs_dir
  ($libs_dir | path join "nu_scripts/themes")
]
