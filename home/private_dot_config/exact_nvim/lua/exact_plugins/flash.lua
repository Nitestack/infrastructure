---@type LazyPluginSpec
return {
  "folke/flash.nvim",
  event = function()
    return {}
  end,
  keys = core.lazy_map({
    [{ "n", "x", "o" }] = {
      [{ "f", "F", "t", "T", ";", "," }] = {},
    },
  }),
  opts = {},
}
