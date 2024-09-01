{
  inputs,
  outputs,
  pkgs,
  ...
}:
let
  username = "nhan";
in
{
  imports = [
    ./ags.nix
    ./browser.nix
    ./git.nix
    ./theme.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.packages = [ ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      bind = [
        "SUPER, Q, killactive"
        "SUPER, Backslash, exec, kitty"
        "ALT, space, exec, wofi --show drun"
        "SUPER, W, exec, firefox"
      ];
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
