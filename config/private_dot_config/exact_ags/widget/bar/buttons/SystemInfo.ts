import { icon } from "lib/utils";
import { df } from "lib/variables";

import PanelButton from "../PanelButton";

export default () => {
  return PanelButton({
    class_name: "system-info",
    visible: df.bind().as((c) => c > 80),
    child: Widget.Box([
      Widget.Icon({ icon: icon("drive-harddisk") }),
      Widget.Label({
        label: df.bind().as((c) => Math.round(c) + "%"),
      }),
    ]),
  });
};
