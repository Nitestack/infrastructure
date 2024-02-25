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
        "Spectre: Global Replace",
      },
    },
  }),
  opts = { open_cmd = "noswapfile vnew" },
}
