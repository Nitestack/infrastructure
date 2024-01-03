---@type LazyPluginSpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = core.lazy_map({
    n = {
      ["<leader>gd"] = {
        function()
          vim.cmd("DiffviewOpen")
        end,
        "DiffView",
      },
    },
  }),
  opts = {},
}
