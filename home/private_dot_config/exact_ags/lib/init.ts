import lowBattery from "./battery";
import gtk from "./gtk";
import hyprland from "./hyprland";
import notifications from "./notifications";
import tmux from "./tmux";

export default function init() {
  try {
    gtk();
    tmux();
    lowBattery();
    notifications();
    hyprland();
  } catch (error) {
    logError(error);
  }
}
