# ╭──────────────────────────────────────────────────────────╮
# │ NIX CONFIGURATION                                        │
# ╰──────────────────────────────────────────────────────────╯

{
  inputs,
  outputs,
  pkgs,
  meta,
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

  # ── Overlays ──────────────────────────────────────────────────────────
  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

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

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs outputs meta;
    };
    users.${meta.username} = import ../home-manager/home.nix;
  };

  # ── Users ─────────────────────────────────────────────────────────────
  users = {
    users = {
      ${meta.username} = {
        isNormalUser = true;
        description = meta.description;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAE51+iQSvnNjWATieu+alWv351eNsQmF7jRXUvty/ZH nhan@nixos"
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
  programs.nix-ld.enable = true;
}
