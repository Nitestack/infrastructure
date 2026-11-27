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
      # Installed for opt-in pilot benchmarking via host-local T3 env; do not set global
      # RUSTC_WRAPPER until nixpkgs ships sccache >= 0.20.0 (rustc 1.100+ compat).
      sccache

      sea-orm-cli
    ];
    sessionVariables.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
  programs = {
    bacon.enable = true;
    cargo.enable = true;
  };
}
