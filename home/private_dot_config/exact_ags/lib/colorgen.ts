// ╭─────────────────────────────────────────────────────────╮
// │ COLOR GENERATION                                        │
// ╰─────────────────────────────────────────────────────────╯

import { bash, dependencies } from "lib/utils";
import options from "options";
import { hyprland as _hyprland } from "resource:///com/github/Aylur/ags/service/hyprland.js";

export default function init() {
  options.theme.light.primary.bg.connect("changed", () => colorgen("gtk"));
  options.theme.light.primary.fg.connect("changed", () => colorgen("gtk"));
  options.theme.light.error.bg.connect("changed", () => colorgen("gtk"));
  options.theme.light.error.fg.connect("changed", () => colorgen("gtk"));
  options.theme.light.bg.connect("changed", () => colorgen("gtk"));
  options.theme.light.fg.connect("changed", () => colorgen("gtk"));
  options.theme.light.surface.bg.connect("changed", () =>
    colorgen("gtk", "hypr")
  );
  options.theme.light.surface.fg.connect("changed", () =>
    colorgen("gtk", "hypr")
  );
  options.theme.light.container.bg.connect("changed", () => colorgen("gtk"));
  options.theme.light.container.fg.connect("changed", () => colorgen("gtk"));
  options.theme.light.inactiveBorder.connect("changed", () => colorgen("hypr"));

  options.theme.dark.primary.bg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.primary.fg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.error.bg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.error.fg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.bg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.fg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.surface.bg.connect("changed", () =>
    colorgen("gtk", "hypr")
  );
  options.theme.dark.surface.fg.connect("changed", () =>
    colorgen("gtk", "hypr")
  );
  options.theme.dark.container.bg.connect("changed", () => colorgen("gtk"));
  options.theme.dark.container.fg.connect("changed", () => colorgen("gtk"));
  options.theme.light.inactiveBorder.connect("changed", () => colorgen("hypr"));

  colorgen("all");
}

// ── GTK Theme ───────────────────────────────────────────────────────
const presetPath = "/tmp/gradience-preset.json";

function overridePresetTemplate(palette: Record<string, string>) {
  return bash(
    Object.keys(palette)
      .map(
        (prop) => `sed -i "s/{{ \\$${prop} }}/${palette[prop]}/g" ${presetPath}`
      )
      .join("\n")
  );
}

function generateGTKTheme() {
  if (!dependencies("gradience-cli")) return;

  const colorPalette =
    options.theme.scheme.value === "dark"
      ? options.theme.dark
      : options.theme.light;

  return bash(
    `cp ${App.configDir}/templates/gradience/preset.json ${presetPath}`
  ).then(() => {
    overridePresetTemplate({
      primary: colorPalette.primary.bg.value,
      onPrimary: colorPalette.primary.fg.value,
      error: colorPalette.error.bg.value,
      onError: colorPalette.error.fg.value,
      background: colorPalette.bg.value,
      onBackground: colorPalette.fg.value,
      surface: colorPalette.surface.bg.value,
      onSurface: colorPalette.surface.fg.value,
      container: colorPalette.container.bg.value,
      onContainer: colorPalette.container.fg.value,
    }).then(() => {
      bash("mkdir -p ~/.config/presets").then(() => {
        bash(`gradience-cli apply -p ${presetPath} --gtk both`).then(() => {
          options.theme.scheme.emit("changed");
          bash(`rm -rf ${presetPath}`);
        });
      });
    });
  });
}

// ── Hyprland ────────────────────────────────────────────────────────
function sendBatch(batch: string[]) {
  const cmd = batch
    .filter((x) => !!x)
    .map((x) => `keyword ${x}`)
    .join("; ");

  return _hyprland.messageAsync(`[[BATCH]]/${cmd}`);
}

function generateHyprlandTheme() {
  const colorPalette =
    options.theme.scheme.value === "dark"
      ? options.theme.dark
      : options.theme.light;
  return sendBatch([
    `general:col.active_border rgba(${colorPalette.surface.fg.value.replace("#", "")}39)`,
    `general:col.inactive_border rgba(${colorPalette.inactiveBorder.value.replace("#", "")}30)`,
    `misc:background_color rgba(${colorPalette.surface.bg.value.replace("#", "")}FF)`,
  ]);
}

// ── Color Generation ────────────────────────────────────────────────
export async function colorgen(...generate: ("gtk" | "hypr" | "all")[]) {
  if (generate.includes("gtk") || generate.includes("all")) generateGTKTheme();
  if (generate.includes("hypr") || generate.includes("all"))
    generateHyprlandTheme();
}
