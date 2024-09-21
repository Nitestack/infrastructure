# ╭──────────────────────────────────────────────────────────╮
# │ Theme                                                    │
# ╰──────────────────────────────────────────────────────────╯
{ meta, ... }:
let
  inherit (meta)
    font
    theme
    cursorTheme
    iconTheme
    ;
in
{
  home = {
    packages = [
      font.sans.package
      font.mono.package
      font.emoji.package
    ];
    pointerCursor = cursorTheme // {
      gtk.enable = true;
    };
    sessionVariables = {
      GTK_THEME = theme.name;

      XCURSOR_THEME = cursorTheme.name;
      XCURSOR_SIZE = "${toString cursorTheme.size}";
      HYPRCURSOR_THEME = cursorTheme.name;
      HYPRCURSOR_SIZE = "${toString cursorTheme.size}";
    };
  };

  gtk = {
    inherit theme cursorTheme iconTheme;
    enable = true;
    font = font.sans;
  };
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ font.sans.name ];
      sansSerif = [ font.sans.name ];
      monospace = [ font.mono.name ];
      emoji = [ font.emoji.name ];
    };
  };

  dconf = {
    enable = true;
    settings =
      let
        # GTK settings
        gtk_settings = {
          show-hidden = true;
          sort-directories-first = true;
          startup-mode = "cwd";
        };
      in
      {
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
}
