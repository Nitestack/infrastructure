return utils.plugin.with_extensions({
  {
    "rcarriga/nvim-notify",
    ---@module "notify"
    ---@type notify.Config
    opts = {
      stages = core.config.performance_mode and "static" or "fade_in_slide_out",
      fps = not core.config.performance_mode and 144 or 30,
    },
  },
}, {
  catppuccin = {
    notify = true,
  },
})
