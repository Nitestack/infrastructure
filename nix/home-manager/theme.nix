# ╭──────────────────────────────────────────────────────────╮
# │ THEME                                                    │
# ╰──────────────────────────────────────────────────────────╯

{
  pkgs,
  ...
}:
let
  gtk_settings = {
    show-hidden = true;
    sort-directories-first = true;
    startup-mode = "cwd";
  };
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "WhiteSur";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 24;
    };
    font = {
      name = "Rubik";
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        clock-format = "24h";
        font-antialiasing = "rgba";
        font-hinting = "full";
        monospace-font-name = "MonaspiceNe Nerd Font";
        show-battery-percentage = true;
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "icon-view";
        show-delete-permanently = true;
      };
      "org/gnome/calculator" = {
        show-thousands = true;
      };
      "org/gtk/settings/file-chooser" = gtk_settings;
      "org/gtk/gtk4/settings/file-chooser" = gtk_settings;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
