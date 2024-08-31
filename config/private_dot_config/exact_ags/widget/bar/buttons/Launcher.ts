import options from "options";

import PanelButton from "../PanelButton";

const { icon, label, action } = options.bar.launcher;

function Spinner() {
  const child = Widget.Icon({
    icon: icon.icon.bind(),
    class_name: Utils.merge(
      [icon.colored.bind()],
      (c) => `${c ? "colored" : ""}`
    ),
    css: `
            @keyframes spin {
                to { -gtk-icon-transform: rotate(1turn); }
            }
        `,
  });

  return Widget.Revealer({
    transition: "slide_left",
    child,
    reveal_child: Utils.merge([icon.icon.bind()], (i) => Boolean(i)),
  });
}

export default () =>
  PanelButton({
    window: "launcher",
    on_clicked: action.bind(),
    child: Widget.Box([
      Spinner(),
      Widget.Label({
        class_name: label.colored.bind().as((c) => (c ? "colored" : "")),
        visible: label.label.bind().as((v) => !!v),
        label: label.label.bind(),
      }),
    ]),
  });
