---@type LazyPluginSpec
return utils.plugin.with_extensions({
  {
    "saghen/blink.cmp",
    opts = {
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
  },
}, {
  catppuccin = {
    blink_cmp = {
      style = "solid",
    },
  },
})
