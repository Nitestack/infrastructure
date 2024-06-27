// ╭─────────────────────────────────────────────────────────╮
// │ COLOR GENERATION                                        │
// ╰─────────────────────────────────────────────────────────╯

import { bash, dependencies } from "lib/utils";
import options from "options";
import { hyprland as _hyprland } from "resource:///com/github/Aylur/ags/service/hyprland.js";

export default function init() {
  const gtkOnlyArgs = ["changed", () => colorgen("gtk")] as const;

  // Primary
  options.theme.light.primary.bg.connect(...gtkOnlyArgs);
  options.theme.light.primary.accent.connect(...gtkOnlyArgs);
  options.theme.dark.primary.bg.connect(...gtkOnlyArgs);
  options.theme.dark.primary.accent.connect(...gtkOnlyArgs);
  // Error
  options.theme.light.error.bg.connect(...gtkOnlyArgs);
  options.theme.light.error.accent.connect(...gtkOnlyArgs);
  options.theme.dark.error.bg.connect(...gtkOnlyArgs);
  options.theme.dark.error.accent.connect(...gtkOnlyArgs);
  // Success
  options.theme.light.success.bg.connect(...gtkOnlyArgs);
  options.theme.light.success.accent.connect(...gtkOnlyArgs);
  options.theme.dark.success.bg.connect(...gtkOnlyArgs);
  options.theme.dark.success.accent.connect(...gtkOnlyArgs);
  // Warning
  options.theme.light.warning.bg.connect(...gtkOnlyArgs);
  options.theme.light.warning.accent.connect(...gtkOnlyArgs);
  options.theme.dark.warning.bg.connect(...gtkOnlyArgs);
  options.theme.dark.warning.accent.connect(...gtkOnlyArgs);

  options.theme.light.fg.connect("changed", () => colorgen("gtk", "hypr"));
  options.theme.dark.fg.connect("changed", () => colorgen("gtk", "hypr"));
  options.theme.light.bg.connect(...gtkOnlyArgs);
  options.theme.dark.bg.connect(...gtkOnlyArgs);
  options.theme.light.view.connect(...gtkOnlyArgs);
  options.theme.dark.view.connect(...gtkOnlyArgs);
  options.theme.light.card.connect(...gtkOnlyArgs);
  options.theme.dark.card.connect(...gtkOnlyArgs);
  options.theme.light.surface.connect(...gtkOnlyArgs);
  options.theme.dark.surface.connect(...gtkOnlyArgs);

  // Inactive Border
  options.theme.light.inactiveBorder.connect("changed", () => colorgen("hypr"));
  options.theme.dark.inactiveBorder.connect("changed", () => colorgen("hypr"));

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

  bash(
    `cp ${App.configDir}/templates/gradience/preset.json ${presetPath}`
  ).then(() => {
    overridePresetTemplate({
      primaryAccent: colorPalette.primary.accent.value,
      primary: colorPalette.primary.bg.value,
      onPrimary: colorPalette.fg.value,

      errorAccent: colorPalette.error.accent.value,
      error: colorPalette.error.bg.value,
      onError: colorPalette.fg.value,

      successAccent: colorPalette.success.accent.value,
      success: colorPalette.success.bg.value,
      onSuccess: colorPalette.fg.value,

      warningAccent: colorPalette.warning.accent.value,
      warning: colorPalette.warning.bg.value,
      onWarning: colorPalette.fg.value,

      background: colorPalette.bg.value,
      onBackground: colorPalette.fg.value,

      view: colorPalette.view.value,
      onView: colorPalette.fg.value,

      card: colorPalette.card.value,
      onCard: colorPalette.fg.value,

      surface: colorPalette.surface.value,
      onSurface: colorPalette.fg.value,
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
  sendBatch([
    `general:col.active_border rgba(${colorPalette.fg.value.replace("#", "")}39)`,
    `general:col.inactive_border rgba(${colorPalette.inactiveBorder.value.replace("#", "")}30)`,
    `misc:background_color rgba(${colorPalette.view.value.replace("#", "")}FF)`,
  ]);
}

// ── Color Generation ────────────────────────────────────────────────
type GenerationType = "gtk" | "hypr";
export async function colorgen(...generate: (GenerationType | "all")[]) {
  const genMap: Record<GenerationType, () => void> = {
    gtk: generateGTKTheme,
    hypr: generateHyprlandTheme,
  };
  for (const genKey of Object.keys(genMap)) {
    if (
      generate.includes("all") ??
      generate.includes(genKey as GenerationType)
    ) {
      genMap[genKey as GenerationType]();
    }
  }
}
