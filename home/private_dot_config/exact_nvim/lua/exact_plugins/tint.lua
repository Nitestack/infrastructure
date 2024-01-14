---@type LazyPluginSpec
return {
  "levouh/tint.nvim",
  event = "VeryLazy",
  opts = {
    tint = -80,
    highlight_ignore_patterns = {
      "SymbolUsage*",
      "LineNr",
      "CursorLineNr",
      "Comment",
    },
  },
}
