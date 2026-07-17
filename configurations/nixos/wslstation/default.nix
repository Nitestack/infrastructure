# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Configuration                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  inherit (config) meta;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./sops.nix

    self.nixosModules.base
    self.nixosModules.interactive-only
  ];
  wsl = {
    enable = true;
    defaultUser = meta.username;
    docker-desktop.enable = true;
    # NOTE: with a Docker Desktop update, this suddenly must be set
    extraBin = [
      { src = "${pkgs.coreutils}/bin/mv"; }
    ];
    ssh-agent.enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
    wslConf = {
      network.hostname = "wslstation";
      interop.appendWindowsPath = false;
    };
  };

  # Packages
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "clip.exe" ''
      exec /mnt/c/Windows/System32/clip.exe "$@"
    '')
    (pkgs.writeShellScriptBin "powershell.exe" ''
      exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe "$@"
    '')
  ];

  systemd.tmpfiles.rules = [
    "d /usr/bin 0755 root root - -"
    "L+ /usr/bin/bash - - - - ${pkgs.bashInteractive}/bin/bash"
  ];

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [
      (self + /configurations/home/wsl.nix)
    ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-linux";
}
