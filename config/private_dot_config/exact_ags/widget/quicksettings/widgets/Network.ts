import icons from "lib/icons.js";
import { dependencies, sh } from "lib/utils";
import options from "options";

import { ArrowToggleButton, Menu } from "../ToggleButton";

const network = await Service.import("network");

export const NetworkIndicator = () =>
  Widget.Stack({
    children: {
      wifi: WifiToggle(),
      wired: EthernetIndicator(),
    },
    shown: network.bind("primary").as((p) => p ?? "wifi"),
  });

export const WifiToggle = () =>
  ArrowToggleButton({
    name: "network",
    icon: network.wifi.bind("icon_name"),
    label: network.wifi.bind("ssid").as((ssid) => ssid ?? "Not Connected"),
    connection: [network.wifi, () => network.wifi.enabled],
    deactivate: () => (network.wifi.enabled = false),
    activate: () => {
      network.wifi.enabled = true;
      network.wifi.scan();
    },
  });

export const EthernetIndicator = () =>
  Widget.Button({
    class_name: "simple-toggle",
    setup: (self) =>
      self.hook(network.wired, () => {
        self.toggleClassName("active", network.wired.internet === "connected");
      }),
    child: Widget.Box([
      Widget.Icon({ icon: network.wired.bind("icon_name") }),
      Widget.Label({
        max_width_chars: 10,
        truncate: "end",
        label: network.wired
          .bind("internet")
          .as(
            (internet) => `${internet[0]!.toUpperCase()}${internet.slice(1)}`
          ),
      }),
    ]),
  });

export const WifiSelection = () =>
  Menu({
    name: "network",
    icon: network.wifi.bind("icon_name"),
    title: "Wifi Selection",
    content: [
      Widget.Box({
        vertical: true,
        setup: (self) =>
          self.hook(
            network.wifi,
            () =>
              (self.children = network.wifi.access_points
                .sort((a, b) => b.strength - a.strength)
                .slice(0, 10)
                .map((ap) =>
                  Widget.Button({
                    on_clicked: () => {
                      if (dependencies("nmcli"))
                        Utils.execAsync(
                          `nmcli device wifi connect ${ap.bssid}`
                        );
                    },
                    child: Widget.Box({
                      children: [
                        Widget.Icon(ap.iconName),
                        Widget.Label(ap.ssid ?? ""),
                        Widget.Icon({
                          icon: icons.ui.tick,
                          hexpand: true,
                          hpack: "end",
                          setup: (self) =>
                            Utils.idle(() => {
                              if (!self.is_destroyed) self.visible = ap.active;
                            }),
                        }),
                      ],
                    }),
                  })
                ))
          ),
      }),
      Widget.Separator(),
      Widget.Button({
        on_clicked: () => sh(options.quicksettings.networkSettings.value),
        child: Widget.Box({
          children: [Widget.Icon(icons.ui.settings), Widget.Label("Network")],
        }),
      }),
    ],
  });
