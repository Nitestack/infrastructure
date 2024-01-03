---@type LazyPluginSpec
return {
  "NTBBloodbath/color-converter.nvim",
  keys = core.lazy_map({
    n = {
      ["<leader>cc"] = {
        function()
          require("color-converter").cycle()
        end,
        "Color Converter: Cycle",
      },
    },
  }),
}
