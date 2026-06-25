# ╭──────────────────────────────────────────────────────────╮
# │ Interactive Only Configuration                           │
# ╰──────────────────────────────────────────────────────────╯
{
  imports = [
    ../shared/system/interactive-only.nix
  ];

  # ── Programs ──────────────────────────────────────────────────────────
  programs.java.enable = true;
}
