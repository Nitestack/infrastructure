# ╭──────────────────────────────────────────────────────────╮
# │ Desktop Services                                         │
# ╰──────────────────────────────────────────────────────────╯
{ pkgs, ... }:
{
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  services = {
    blueman.enable = true;
    playerctld.enable = true;
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
}
