import options from "options";

import { sh } from "./utils";

export async function tmux() {
  const { scheme, dark, light } = options.theme;
  const hex =
    scheme.value === "dark"
      ? dark.primary.accent.value
      : light.primary.accent.value;
  if (await sh("which tmux").catch(() => false))
    sh(`tmux set @main_accent "${hex}"`);
}

export default function init() {
  options.theme.dark.primary.accent.connect("changed", tmux);
  options.theme.light.primary.accent.connect("changed", tmux);
}
