---@type LazyPluginSpec
return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        winhighlight = "Normal:Normal,PmenuExtra:Normal",
        border = "rounded",
      },
    },
    keymap = {
      preset = "default",
    },
    cmdline = {
      enabled = true,
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
  },
}
