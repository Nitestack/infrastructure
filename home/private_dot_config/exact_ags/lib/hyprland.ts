import options from "options";

const { messageAsync } = await Service.import("hyprland");

const {
  hyprland,
  theme: {
    spacing,
    radius,
    border: { width },
    blur,
    shadows,
  },
} = options;

const deps = ["hyprland", spacing.id, radius.id, blur.id, width.id, shadows.id];

function sendBatch(batch: string[]) {
  const cmd = batch
    .filter((x) => !!x)
    .map((x) => `keyword ${x}`)
    .join("; ");

  return messageAsync(`[[BATCH]]/${cmd}`);
}

async function setupHyprland() {
  const wm_gaps = Math.floor(hyprland.gaps.value * spacing.value);

  sendBatch([
    `general:border_size ${width.value}`,
    `general:gaps_out ${wm_gaps}`,
    `general:gaps_in ${Math.floor(wm_gaps / 2)}`,
    `decoration:rounding ${radius.value}`,
    `decoration:drop_shadow ${shadows.value ? "yes" : "no"}`,
  ]);

  await sendBatch(App.windows.map(({ name }) => `layerrule unset, ${name}`));

  if (blur.value > 0) {
    sendBatch(
      App.windows.flatMap(({ name }) => [
        `layerrule unset, ${name}`,
        `layerrule blur, ${name}`,
        `layerrule ignorealpha ${/* based on shadow color */ 0.29}, ${name}`,
      ])
    );
  }
}

export default function init() {
  options.handler(deps, setupHyprland);
  setupHyprland();
}
