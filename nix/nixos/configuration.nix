{
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ./audio.nix
    ./hyprland.nix
    ./locale.nix
    ./system.nix
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
  };

  users = {
    users = {
      "nhan" = {
        isNormalUser = true;
        description = "Nhan Pham";
        openssh.authorizedKeys.keys = [
          # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
        ];
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "libvirtd"
        ];
      };
    };
    defaultUserShell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.tmux.enable = true;
}
