# ╭──────────────────────────────────────────────────────────╮
# │ Nix Home Manager Configuration                           │
# ╰──────────────────────────────────────────────────────────╯
_: {
  imports = [
    ./profiles/ai.nix
    ./profiles/core.nix
    ./profiles/dev.nix
    ./profiles/editor.nix
  ];
}
