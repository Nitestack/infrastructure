# ╭──────────────────────────────────────────────────────────╮
# │ Herdr                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ lib, ... }:
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      terminal.default_shell = "nu";
      keys.prefix = "ctrl+a";
      ui.toast.delivery = "system";
    };
  };

  programs.ssh.settings.homestation = lib.hm.dag.entryBefore [ "*" ] {
    HostName = "192.168.178.20";
    ServerAliveInterval = 30;
    ControlMaster = "auto";
    ControlPersist = "10m";
  };

  home.shellAliases.herdr-server = "herdr --remote homestation --session server";
}
