# ╭──────────────────────────────────────────────────────────╮
# │ Rust                                                     │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      cargo
      clippy
      rust-analyzer
      rustc
      rustfmt
    ];
    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
    ];
    sessionVariables.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
