const main = "/tmp/asztal/main.js";
const entry = `${App.configDir}/main.ts`;

try {
  await Utils.execAsync([
    "esbuild",
    "--bundle",
    entry,
    "--format=esm",
    `--outfile=${main}`,
    "--external:resource://*",
    "--external:gi://*",
    "--external:file://*",
  ]);

  await import(`file://${main}`);
} catch (error) {
  console.error(error);
  App.quit();
}

export {};
