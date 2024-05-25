---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  event = function()
    return {}
  end,
  keys = core.lazy_map({
    n = {
      [{ "<leader>", "<C-r>", "<C-w>", "\"", "'", "`", "c", "v", "g" }] = {},
    },
  }),
  ---@type Options
  opts = {
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "Goto" },
      ["z"] = { name = "Fold" },
      ["]"] = { name = "Next" },
      ["["] = { name = "Previous" },
      ["<C-w>"] = { name = "Window" },
      ["<leader>"] = { name = "Leader" },
      ["<leader>c"] = { name = "Code" },
      ["<leader>f"] = { name = "File/Find" },
      ["<leader>g"] = { name = "Git" },
      ["<leader>gh"] = { name = "Hunks" },
      ["<leader>q"] = { name = "Quit/Session" },
      ["<leader>s"] = { name = "Search" },
      ["<leader>u"] = { name = "UI" },
      ["<leader>w"] = { name = "Windows" },
      ["<leader>x"] = { name = "Diagnostics/Quickfix/Location" },
    },
    icons = {
      breadcrumb = core.icons.ui.DoubleChevronRight,
      separator = "",
      group = "",
    },
    window = {
      border = core.config.ui.transparent.floats and "rounded" or "none",
    },
  },
}
