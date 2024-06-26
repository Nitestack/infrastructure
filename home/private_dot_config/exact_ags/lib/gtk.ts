import Gio from "gi://Gio";
import options from "options";
import { ICON_THEME } from "template";

const settings = new Gio.Settings({
  schema: "org.gnome.desktop.interface",
});

function gtk() {
  const scheme = options.theme.scheme.value;
  const suffixLower = options.theme.scheme.value === "dark" ? "-dark" : "";
  const suffixUpper = options.theme.scheme.value === "dark" ? "-Dark" : "";
  settings.set_string("color-scheme", `prefer-${scheme}`);
  settings.set_string("gtk-theme", `adw-gtk3${suffixLower}`);
  settings.set_string("icon-theme", `${ICON_THEME}${suffixUpper}`);
}

export default function init() {
  options.theme.scheme.connect("changed", gtk);
  gtk();
}
