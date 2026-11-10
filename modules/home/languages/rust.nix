# ╭──────────────────────────────────────────────────────────╮
# │ Rust                                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      clippy
      rust-analyzer
      rustc
      rustfmt

      cargo-watch
      cargo-expand

      sea-orm-cli
    ];
    sessionVariables.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
  programs = {
    bacon.enable = true;
    cargo.enable = true;
  };
}
