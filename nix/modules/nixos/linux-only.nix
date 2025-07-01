# ╭──────────────────────────────────────────────────────────╮
# │ Linux Only Configuration                                 │
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
  # Nix
  documentation.nixos.enable = false;

  # ── Users ─────────────────────────────────────────────────────────────
  users = {
    users.${meta.username} = {
      isNormalUser = true;
      extraGroups = [
        "audio"
        "docker"
        "libvirtd"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
    defaultUserShell = pkgs.zsh;
  };

  # ── Programs ──────────────────────────────────────────────────────────
  programs = {
    gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
    java.enable = true;
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
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true; # Enable mDNS for IPv4
      nssmdns6 = true; # Enable mDNS for IPv6
      ipv4 = true; # Ensure IPv4 support
      ipv6 = true; # Ensure IPv6 support
      openFirewall = true; # Open the firewall for Avahi
    };
    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };
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
