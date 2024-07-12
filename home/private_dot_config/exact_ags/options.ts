import icons from "lib/icons";
import { mkOptions, opt } from "lib/option";
import { icon } from "lib/utils";
import { distro } from "lib/variables";
import { FONT_SANS_FAMILY, IS_NOT_VM, THEME } from "template";

const options = mkOptions(OPTIONS, {
  theme: {
    dark: {
      primary: {
        bg: opt(THEME.dark.primary.bg),
        accent: opt(THEME.dark.primary.accent),
      },
      error: {
        bg: opt(THEME.dark.error.bg),
        accent: opt(THEME.dark.error.accent),
      },
      success: {
        bg: opt(THEME.dark.success.bg),
        accent: opt(THEME.dark.success.accent),
      },
      warning: {
        bg: opt(THEME.dark.warning.bg),
        accent: opt(THEME.dark.warning.accent),
      },
      fg: opt(THEME.dark.fg),
      bg: opt(THEME.dark.bg),
      view: opt(THEME.dark.view),
      card: opt(THEME.dark.card),
      surface: opt(THEME.dark.surface),

      widget: opt(THEME.dark.widget),
      border: opt(THEME.dark.border),
      inactiveBorder: opt(THEME.dark.inactiveBorder),
    },
    light: {
      primary: {
        bg: opt(THEME.light.primary.bg),
        accent: opt(THEME.light.primary.accent),
      },
      error: {
        bg: opt(THEME.light.error.bg),
        accent: opt(THEME.light.error.accent),
      },
      success: {
        bg: opt(THEME.light.success.bg),
        accent: opt(THEME.light.success.accent),
      },
      warning: {
        bg: opt(THEME.light.warning.bg),
        accent: opt(THEME.light.warning.accent),
      },
      fg: opt(THEME.light.fg),
      bg: opt(THEME.light.bg),
      view: opt(THEME.light.view),
      card: opt(THEME.light.card),
      surface: opt(THEME.light.surface),

      widget: opt(THEME.light.widget),
      border: opt(THEME.light.border),
      inactiveBorder: opt(THEME.light.inactiveBorder),
    },

    blur: opt(15),
    scheme: opt<"dark" | "light">(THEME.colorscheme),
    widget: { opacity: opt(THEME.widget.opacity) },
    border: {
      width: opt(THEME.border.width),
      opacity: opt(THEME.border.opacity),
    },

    shadows: opt(IS_NOT_VM),
    padding: opt(THEME.padding),
    spacing: opt(THEME.spacing),
    radius: opt(THEME.radius),
  },

  transition: opt(200),

  font: {
    size: opt(13),
    name: opt<string>(FONT_SANS_FAMILY),
  },

  bar: {
    flatButtons: opt(false),
    position: opt<"top" | "bottom">("top"),
    corners: opt(50),
    transparent: opt(true),
    layout: {
      start: opt<import("widget/bar/Bar").BarWidget[]>([
        "launcher",
        "workspaces",
        "taskbar",
        "expander",
        "messages",
      ]),
      center: opt<import("widget/bar/Bar").BarWidget[]>(["date"]),
      end: opt<import("widget/bar/Bar").BarWidget[]>([
        "media",
        "expander",
        "systray",
        "colorpicker",
        "screenrecord",
        "hyprshade",
        "system-info",
        "system",
        "battery",
        "powermenu",
      ]),
    },
    launcher: {
      icon: {
        colored: opt(true),
        icon: opt(icon(distro.logo, icons.ui.search)),
      },
      label: {
        colored: opt(false),
        label: opt(" Arch Linux"),
      },
      action: opt(() => App.toggleWindow("launcher")),
    },
    date: {
      format: opt("%H:%M - %A, %B %e, %Y"),
      action: opt(() => App.toggleWindow("datemenu")),
    },
    battery: {
      bar: opt<"hidden" | "regular" | "whole">("hidden"),
      charging: opt("#00D787"),
      percentage: opt(true),
      blocks: opt(7),
      width: opt(50),
      low: opt(30),
    },
    workspaces: {
      workspaces: opt(10),
    },
    taskbar: {
      iconSize: opt(0),
      monochrome: opt(false),
      exclusive: opt(false),
    },
    messages: {
      action: opt(() => App.toggleWindow("datemenu")),
    },
    systray: {
      ignore: opt(["KDE Connect Indicator", "spotify-client"]),
    },
    media: {
      monochrome: opt(false),
      preferred: opt("spotify"),
      direction: opt<"left" | "right">("right"),
      format: opt("{artists} - {title}"),
      length: opt(40),
    },
    powermenu: {
      monochrome: opt(false),
      action: opt(() => App.toggleWindow("powermenu")),
    },
  },

  launcher: {
    width: opt(0),
    margin: opt(80),
    sh: {
      max: opt(16),
    },
    cliphist: {
      max: opt(16),
    },
    apps: {
      iconSize: opt(62),
      max: opt(6),
      favorites: opt([
        ["firefox", "wezterm", "org.gnome.Nautilus", "ferdium", "spotify"],
      ]),
    },
  },

  overview: {
    scale: opt(9),
    workspaces: opt(10),
    monochromeIcon: opt(false),
  },

  powermenu: {
    sleep: opt("systemctl suspend"),
    reboot: opt("systemctl reboot"),
    logout: opt("pkill Hyprland"),
    shutdown: opt("shutdown now"),
    layout: opt<"line" | "box">("line"),
    labels: opt(true),
  },

  quicksettings: {
    avatar: {
      image: opt(`${Utils.HOME}/Pictures/user-avatar.png`),
      size: opt(70),
    },
    width: opt(380),
    position: opt<"left" | "center" | "right">("right"),
    networkSettings: opt("gnome-control-center wifi"),
    media: {
      monochromeIcon: opt(false),
      coverSize: opt(100),
    },
  },

  datemenu: {
    position: opt<"left" | "center" | "right">("center"),
  },

  hyprshade: {
    interval: opt(10000),
  },

  osd: {
    progress: {
      vertical: opt(true),
      pack: {
        h: opt<"start" | "center" | "end">("end"),
        v: opt<"start" | "center" | "end">("center"),
      },
    },
    microphone: {
      pack: {
        h: opt<"start" | "center" | "end">("center"),
        v: opt<"start" | "center" | "end">("end"),
      },
    },
  },

  notifications: {
    position: opt<("top" | "bottom" | "left" | "right")[]>(["top", "right"]),
    blacklist: opt(["Spotify"]),
    width: opt(440),
  },

  hyprland: {
    gaps: opt(THEME.window_margin),
  },
});

Object.assign(globalThis, { options });
export default options;
