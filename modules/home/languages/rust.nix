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
      bacon

      cargo-watch
      cargo-expand

      sea-orm-cli
    ];
    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
    ];
    sessionVariables.RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
