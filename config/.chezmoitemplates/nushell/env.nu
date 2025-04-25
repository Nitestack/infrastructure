# ╭──────────────────────────────────────────────────────────╮
# │ Nushell Environment                                      │
# ╰──────────────────────────────────────────────────────────╯

# ── Initialization Script Generation ──────────────────────────────────
# Sourcing of Nu Script Generation in `config.nu`

# Carapace
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"
carapace _carapace nushell | save -f $"($nu.default-config-dir)/.carapace.nu"

# Oh My Posh
oh-my-posh init nu --config ~/.config/oh-my-posh/config.yml --print | save -f $"($nu.default-config-dir)/.oh-my-posh.nu"

# Zoxide
zoxide init nushell --cmd cd | save -f $"($nu.default-config-dir)/.zoxide.nu"
