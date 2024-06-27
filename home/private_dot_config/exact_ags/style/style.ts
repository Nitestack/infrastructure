import { bash, dependencies } from "lib/utils";
import options from "options";

const deps = [
  "font",
  "theme",
  "bar.corners",
  "bar.flatButtons",
  "bar.position",
  "bar.battery.charging",
  "bar.battery.blocks",
];

const {
  dark,
  light,
  blur,
  scheme,
  padding,
  spacing,
  radius,
  shadows,
  widget,
  border,
} = options.theme;

const popoverPaddingMultiplier = 1.6;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const t = (dark: string, light: string) =>
  scheme.value === "dark" ? `${dark}` : `${light}`;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const $ = (name: string, value: string | number) => `$${name}: ${value};`;

const variables = () => [
  $(
    "bg",
    blur.value
      ? `transparentize(${t(dark.bg.value, light.bg.value)}, ${blur.value / 100})`
      : t(dark.bg.value, light.bg.value)
  ),
  $("fg", t(dark.fg.value, light.fg.value)),

  $("primary-bg", t(dark.primary.accent.value, light.primary.accent.value)),
  $("primary-fg", t(dark.fg.value, light.fg.value)),

  $("error-bg", t(dark.error.accent.value, light.error.bg.value)),
  $("error-fg", t(dark.fg.value, light.fg.value)),

  $("scheme", scheme.value),
  $("padding", `${padding.value}pt`),
  $("spacing", `${spacing.value}pt`),
  $("radius", `${radius.value}px`),
  $("transition", `${options.transition.value}ms`),

  $("shadows", `${shadows.value}`),

  $(
    "widget-bg",
    `transparentize(${t(dark.widget.value, light.widget.value)}, ${widget.opacity.value / 100})`
  ),

  $(
    "hover-bg",
    `transparentize(${t(dark.widget.value, light.widget.value)}, ${(widget.opacity.value * 0.9) / 100})`
  ),
  $("hover-fg", `lighten(${t(dark.fg.value, light.fg.value)}, 8%)`),

  $("border-width", `${border.width.value}px`),
  $(
    "border-color",
    `transparentize(${t(dark.border.value, light.border.value)}, ${border.opacity.value / 100})`
  ),
  $("border", "$border-width solid $border-color"),

  $(
    "active-gradient",
    `linear-gradient(to right, ${t(dark.primary.accent.value, light.primary.accent.value)}, darken(${t(dark.primary.accent.value, light.primary.accent.value)}, 4%))`
  ),
  $("shadow-color", t("rgba(0,0,0,.6)", "rgba(0,0,0,.4)")),
  $("text-shadow", t("2pt 2pt 2pt $shadow-color", "none")),
  $(
    "box-shadow",
    t(
      "2pt 2pt 2pt 0 $shadow-color, inset 0 0 0 $border-width $border-color",
      "none"
    )
  ),

  $(
    "popover-border-color",
    `transparentize(${t(dark.border.value, light.border.value)}, ${Math.max((border.opacity.value - 1) / 100, 0)})`
  ),
  $("popover-padding", `$padding * ${popoverPaddingMultiplier}`),
  $("popover-radius", radius.value === 0 ? "0" : "$radius + $popover-padding"),

  $("font-size", `${options.font.size.value}pt`),
  $("font-name", options.font.name.value),

  // etc
  $("charging-bg", options.bar.battery.charging.value),
  $("bar-battery-blocks", options.bar.battery.blocks.value),
  $("bar-position", options.bar.position.value),
  $("hyprland-gaps-multiplier", options.hyprland.gaps.value),
  $("screen-corner-multiplier", `${options.bar.corners.value * 0.01}`),
];

async function resetCss() {
  if (!dependencies("sass", "fd")) return;

  try {
    const vars = `${TMP}/variables.scss`;
    const scss = `${TMP}/main.scss`;
    const css = `${TMP}/main.css`;

    const fd = await bash(`fd ".scss" ${App.configDir}`);
    const files = fd.split(/\s+/);
    const imports = [vars, ...files].map((f) => `@import '${f}';`);

    await Utils.writeFile(variables().join("\n"), vars);
    await Utils.writeFile(imports.join("\n"), scss);
    await bash`sass ${scss} ${css}`;

    App.applyCss(css, true);
  } catch (error) {
    error instanceof Error ? logError(error) : console.error(error);
  }
}

Utils.monitorFile(`${App.configDir}/style`, resetCss);
options.handler(deps, resetCss);
await resetCss();
