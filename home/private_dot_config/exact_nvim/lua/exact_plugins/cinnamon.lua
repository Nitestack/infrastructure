---@type LazyPluginSpec
return {
  "declancm/cinnamon.nvim",
  cond = function()
    return not utils.general.is_neovide()
  end,
  event = "LazyFile",
  opts = {
    default_keymaps = true,
    extra_keymaps = true,
    extended_keymaps = true,
    override_keymaps = false,

    default_delay = 1,
    hide_cursor = true,
    horizonal_scroll = false,
    scroll_limit = 50,
  },
}
