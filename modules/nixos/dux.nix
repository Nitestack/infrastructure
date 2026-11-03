# ╭──────────────────────────────────────────────────────────╮
# │ Dux                                                      │
# ╰──────────────────────────────────────────────────────────╯
{
  programs = {
    dux-shell = {
      enable = true;
      systemd.enable = true;
    };
    dux-files = {
      enable = true;
      systemd.enable = true;
      portal.enable = true;
    };
    dux-search = {
      enable = true;
      systemd.enable = true;
    };
    dux-calendar = {
      enable = true;
      systemd.enable = true;
    };
  };

  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "hyprland";
  };

  xdg.portal.config.hyprland."org.freedesktop.impl.portal.FileChooser" = [
    "dfiles"
    "gtk"
  ];
}
