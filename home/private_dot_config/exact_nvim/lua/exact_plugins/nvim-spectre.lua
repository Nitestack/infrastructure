---@type LazyPluginSpec
return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  keys = core.lazy_map({
    n = {
      ["<leader>sr"] = {
        function()
          require("spectre").open()
        end,
        desc = "Spectre: Global Replace",
      },
      ["<leader>sf"] = {
        function()
          require("spectre").open_file_search()
        end,
        desc = "Spectre (current file)",
      },
    },
  }),
  opts = { open_cmd = "noswapfile vnew" },
}
