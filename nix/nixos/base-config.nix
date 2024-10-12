# ╭──────────────────────────────────────────────────────────╮
# │ NIX BASE CONFIGURATION                                   │
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
  };

  # ── Users ─────────────────────────────────────────────────────────────
  users = {
    users = {
      ${meta.username} = {
        isNormalUser = true;
        description = meta.description;
        extraGroups = [
          "audio"
          "docker"
          "libvirtd"
          "networkmanager"
          "video"
          "wheel"
        ];
      };
    };
    defaultUserShell = pkgs.zsh;
  };

  # ── Zsh ───────────────────────────────────────────────────────────────
  programs.zsh.enable = true;
  # zsh completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.tmux.enable = true;
  programs.nix-ld.enable = true;
}
