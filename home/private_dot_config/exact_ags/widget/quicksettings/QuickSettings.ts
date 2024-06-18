import options from "options";
import PopupWindow from "widget/PopupWindow";

import { BluetoothDevices, BluetoothToggle } from "./widgets/Bluetooth";
import { Brightness } from "./widgets/Brightness";
import { DarkModeToggle } from "./widgets/DarkMode";
import { DND } from "./widgets/DND";
import { Header } from "./widgets/Header";
import { Media } from "./widgets/Media";
import { MicMute } from "./widgets/MicMute";
import { NetworkToggle, WifiSelection } from "./widgets/Network";
import { ProfileSelector, ProfileToggle } from "./widgets/PowerProfile";
import { AppMixer, Microphone, SinkSelector, Volume } from "./widgets/Volume";

import type Gtk from "gi://Gtk?version=3.0";

const { bar, quicksettings } = options;
const media = (await Service.import("mpris")).bind("players");
const layout = Utils.derive(
  [bar.position, quicksettings.position],
  (bar, qs) => `${bar}-${qs}` as const
);

const Row = (
  toggles: Array<() => Gtk.Widget> = [],
  menus: Array<() => Gtk.Widget> = []
) =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Box({
        homogeneous: true,
        class_name: "row horizontal",
        children: toggles.map((w) => w()),
      }),
      ...menus.map((w) => w()),
    ],
  });

const Settings = () =>
  Widget.Box({
    vertical: true,
    class_name: "quicksettings vertical",
    css: quicksettings.width.bind().as((w) => `min-width: ${w}px;`),
    children: [
      Header(),
      Widget.Box({
        class_name: "sliders-box vertical",
        vertical: true,
        children: [
          Row([Volume], [SinkSelector, AppMixer]),
          Microphone(),
          Brightness(),
        ],
      }),
      Row([NetworkToggle, BluetoothToggle], [WifiSelection, BluetoothDevices]),
      Row([ProfileToggle, DarkModeToggle], [ProfileSelector]),
      Row([MicMute, DND]),
      Widget.Box({
        visible: media.as((l) => l.length > 0),
        child: Media(),
      }),
    ],
  });

const QuickSettings = () =>
  PopupWindow({
    name: "quicksettings",
    exclusivity: "exclusive",
    transition: bar.position
      .bind()
      .as((pos) => (pos === "top" ? "slide_down" : "slide_up")),
    layout: layout.value,
    child: Settings(),
  });

export function setupQuickSettings() {
  App.addWindow(QuickSettings());
  layout.connect("changed", () => {
    App.removeWindow("quicksettings");
    App.addWindow(QuickSettings());
  });
}
