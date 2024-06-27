import hyprshade from "service/hyprshade";

import PanelButton from "../PanelButton";

export default () => {
  return PanelButton({
    class_name: "hyprshade",
    child: Widget.Icon({
      icon_name: hyprshade.bind("shader").as(() => {
        return hyprshade.isNight
          ? "night-light-symbolic"
          : "night-light-disabled-symbolic";
      }),
    }),
    on_clicked: () => hyprshade.toggle(),
  });
};
