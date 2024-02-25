---@type LazyPluginSpec
return {
  "nvim-tree/nvim-web-devicons",
  opts = {
    override_by_extension = {
      astro = {
        icon = "󱓞",
        color = "#FF7E33",
        name = "astro",
      },
      toml = {
        icon = "",
        color = "#6e8086",
      },
    },
    override_by_filename = {
      [".npmignore"] = {
        icon = "",
        color = "#c63c42",
        name = ".npmignore",
      },
      ["tsconfig.tsbuildinfo"] = {
        icon = "",
        color = "#cbcb41",
        name = "tsconfig.tsbuildinfo",
      },
    },
  },
}
