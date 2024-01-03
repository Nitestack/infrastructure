---@type LazyPluginSpec
return {
  "declancm/cinnamon.nvim",
  event = "LazyFile",
  opts = {
    default_keymaps = true,
    extra_keymaps = true,
    extended_keymaps = true,
    override_keymaps = true,

    hide_cursor = true,
    scroll_limit = 50,
  },
}
