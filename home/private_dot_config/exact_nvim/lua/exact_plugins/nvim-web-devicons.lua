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
    override = {
      deb = { icon = "", name = "Deb" },
      lock = { icon = "󰌾", name = "Lock" },
      mp3 = { icon = "󰎆", name = "Mp3" },
      mp4 = { icon = "", name = "Mp4" },
      out = { icon = "", name = "Out" },
      ["robots.txt"] = { icon = "󰚩", name = "Robots" },
      ttf = { icon = "", name = "TrueTypeFont" },
      rpm = { icon = "", name = "Rpm" },
      woff = { icon = "", name = "WebOpenFontFormat" },
      woff2 = { icon = "", name = "WebOpenFontFormat2" },
      xz = { icon = "", name = "Xz" },
      zip = { icon = "", name = "Zip" },
    },
  },
}
