---@type LazyPluginSpec
return {
  "nvim-pack/nvim-spectre",
  keys = core.lazy_map({
    n = {
      ["<leader>sf"] = {
        function()
          require("spectre").open_file_search()
        end,
        desc = "Spectre (current file)",
      },
    },
  }),
}
