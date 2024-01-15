---@type LazyPluginSpec
return {
  "aznhe21/actions-preview.nvim",
  keys = core.lazy_map({
    [{ "n", "v" }] = {
      ["<leader>ca"] = {
        function()
          require("actions-preview").code_actions()
        end,
        "Code Action",
      },
    },
  }),
  opts = {},
}
