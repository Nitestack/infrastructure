# ╭──────────────────────────────────────────────────────────╮
# │ NixOS WSL Configuration                                  │
# ╰──────────────────────────────────────────────────────────╯
{
  flake,
  config,
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
    ssh-agent.enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
    wslConf.network.hostname = "wslstation";
  };

  wslstation.anthropic = {
    profile = "swtb";
  };

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager.users.${meta.username} = {
    imports = [
      (self + /configurations/home/wsl.nix)
      (self + /modules/home/pi-coding-agent/work-hub.nix)
    ];
  };

  # Configuration
  nixpkgs.hostPlatform = "x86_64-linux";
}
