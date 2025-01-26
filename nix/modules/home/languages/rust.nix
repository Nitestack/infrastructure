# ╭──────────────────────────────────────────────────────────╮
# │ Rust                                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt
  ];
  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
