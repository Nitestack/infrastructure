{
  outputs,
  pkgs,
  ...
}:
let
  username = "nhan";
in
{
  imports = [
    ./git.nix
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;

    systemd.enable = true;

    settings = {
      bind = [
        "ALT, space, exec, wofi --show drun"
        "SUPER, Backslash, exec, kitty"
      ];
    };
  };

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Monaspace" ]; })
  ];

  # Enable home-manager
  programs.home-manager.enable = true;
  programs.lazygit.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
