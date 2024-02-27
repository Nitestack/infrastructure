---@type LazyPluginSpec
return {
  "levouh/tint.nvim",
  event = "WinNew",
  opts = {
    highlight_ignore_patterns = {
      -- "Line*",
      -- "CursorLine*",
      -- "Ibl*",
      -- "MiniIndentscope*",
      "Comment",
    },
  },
}
