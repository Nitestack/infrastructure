const THIRD_PARTY_MODULES = "<THIRD_PARTY_MODULES>"; // Imports not matched by other special words or groups
const BUILTIN_MODULES = "<BUILTIN_MODULES>"; // Node.js built-in modules
const RELATIVE_IMPORTS = "^[.]"; // Relative imports
const TYPES = {
  NODE: "<TYPES>^(node:)", // Types from Node.js built-in modules
  THIRD_PARTY: "<TYPES>", // Types from third party modules
  RELATIVE: "<TYPES>^[.]", // Types from relative imports
};

/** @type {import("prettier").Config & import("@ianvs/prettier-plugin-sort-imports").PluginConfig} */
export default {
  trailingComma: "es5",
  plugins: ["@ianvs/prettier-plugin-sort-imports"],
  // INFO: To group imports into "chunks" with blank lines between, add empty strings
  importOrder: [
    "",
    BUILTIN_MODULES,
    "",
    THIRD_PARTY_MODULES,
    "",
    RELATIVE_IMPORTS,
    "",
    TYPES.NODE,
    TYPES.THIRD_PARTY,
    TYPES.RELATIVE,
  ],
  importOrderTypeScriptVersion: "5.4.3",
};
