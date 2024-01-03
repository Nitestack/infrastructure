---@type LazyPluginSpec
return {
  "cshuaimin/ssr.nvim",
  keys = core.lazy_map({
    [{ "n", "x" }] = {
      ["<leader>sR"] = {
        function()
          require("ssr").open()
        end,
        "Structural Replace",
      },
    },
  }),
}
