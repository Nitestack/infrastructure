# ╭──────────────────────────────────────────────────────────╮
# │ NixOS Base Configuration                                 │
# ╰──────────────────────────────────────────────────────────╯
{
  config,
  pkgs,
  ...
}:
let
  inherit (config) meta;
in
{
  imports = [
    ../shared/system/base.nix
    ./sops.nix
  ];

  # Nix
  documentation.nixos.enable = false;

  # ── Users ─────────────────────────────────────────────────────────────
  users = {
    users.${meta.username} = {
      isNormalUser = true;
      extraGroups = [
        "docker"
        "wheel"
      ];
    };
    defaultUserShell = pkgs.zsh;
  };

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      prompt.enable = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
    nh = {
      enable = true;
      clean.enable = true;
    };
    nix-ld.enable = true;
  };

  # ── Services ──────────────────────────────────────────────────────────
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable mDNS for IPv4
    nssmdns6 = true; # Enable mDNS for IPv6
    ipv4 = true; # Ensure IPv4 support
    ipv6 = true; # Ensure IPv6 support
    openFirewall = true; # Open the firewall for Avahi
  };

  # ── Localization ──────────────────────────────────────────────────────
  i18n =
    let
      english = "en_US.UTF-8";
      german = "de_DE.UTF-8";
    in
    {
      defaultLocale = english;
      extraLocaleSettings = {
        LC_ADDRESS = german;
        LC_IDENTIFICATION = german;
        LC_MEASUREMENT = german;
        LC_MONETARY = german;
        LC_NAME = german;
        LC_NUMERIC = german;
        LC_PAPER = german;
        LC_TELEPHONE = german;
        LC_TIME = german;
      };
    };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
