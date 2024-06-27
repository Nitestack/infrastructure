import icons from "lib/icons";
import { mkOptions, opt } from "lib/option";
import { icon } from "lib/utils";
import { distro } from "lib/variables";
import { FONT_SANS_FAMILY, IS_NOT_VM } from "template";

const options = mkOptions(OPTIONS, {
  theme: {
    dark: {
      primary: {
        bg: opt("#1e66f5"),
        accent: opt("#89b4fa"),
      },
      error: {
        bg: opt("#d20f39"),
        accent: opt("#f38ba8"),
      },
      success: {
        bg: opt("#40a02b"),
        accent: opt("#a6e3a1"),
      },
      warning: {
        bg: opt("#df8e1d"),
        accent: opt("#f9e2af"),
      },
      fg: opt("#cdd6f4"),
      bg: opt("#1e1e2e"),
      view: opt("#181825"),
      card: opt("#11111b"),
      surface: opt("#313244"),

      widget: opt("#cdd6f4"),
      border: opt("#cdd6f4"),
      inactiveBorder: opt("#282828"),
    },
    light: {
      primary: {
        bg: opt("#1e66f5"),
        accent: opt("#8caaee"),
      },
      error: {
        bg: opt("#d20f39"),
        accent: opt("#e78284"),
      },
      success: {
        bg: opt("#40a02b"),
        accent: opt("#a6d189"),
      },
      warning: {
        bg: opt("#df8e1d"),
        accent: opt("#e5c890"),
      },
      fg: opt("#4c4f69"),
      bg: opt("#eff1f5"),
      view: opt("#e6e9ef"),
      card: opt("#dce0e8"),
      surface: opt("#ccd0da"),

      widget: opt("#4c4f69"),
      border: opt("#4c4f69"),
      inactiveBorder: opt("#282828"),
    },

    blur: opt(15),
    scheme: opt<"dark" | "light">("dark"),
    widget: { opacity: opt(94) },
    border: {
      width: opt(1),
      opacity: opt(96),
    },

    shadows: opt(IS_NOT_VM),
    padding: opt(7),
    spacing: opt(12),
    radius: opt(11),
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
      image: opt(`${Utils.HOME}/Pictures/user-avatar.jpg`),
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
    gaps: opt(2.4),
  },
});

globalThis.options = options;
export default options;
