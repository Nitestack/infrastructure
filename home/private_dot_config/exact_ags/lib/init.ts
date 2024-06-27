import lowBattery from "./battery";
import colorgen from "./colorgen";
import gtk from "./gtk";
import hyprland from "./hyprland";
import notifications from "./notifications";
import tmux from "./tmux";

export default function init() {
  try {
    gtk();
    tmux();
    colorgen();
    hyprland();
    lowBattery();
    notifications();
  } catch (error) {
    logError(error);
  }
}
