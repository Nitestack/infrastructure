---@type LazyPluginSpec
return {
  "smjonas/inc-rename.nvim",
  dependencies = {
    "stevearc/dressing.nvim",
  },
  cmd = "IncRename",
  opts = {
    input_buffer_type = "dressing",
  },
}
