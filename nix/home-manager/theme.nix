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
  cursor_settings = {
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 24;
  };
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "WhiteSur";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = cursor_settings;
    font = {
      name = "Rubik";
      package = pkgs.rubik;
    };
  };

  home.pointerCursor = cursor_settings // {
    gtk.enable = true;
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
