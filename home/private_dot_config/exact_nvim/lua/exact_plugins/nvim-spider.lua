---@type LazyPluginSpec
return {
  "chrisgrieser/nvim-spider",
  keys = core.lazy_map({
    [{ "n", "o", "x" }] = {
      ["e"] = {
        function()
          require("spider").motion("e")
        end,
        "Move to next word (e)",
      },
      ["w"] = {
        function()
          require("spider").motion("w")
        end,
        "Move to next word (w)",
      },
      ["b"] = {
        function()
          require("spider").motion("b")
        end,
        "Move to previous word (b)",
      },
    },
  }),
  opts = {
    skipInsignificantPunctuation = false,
  },
}
