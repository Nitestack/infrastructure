---@type LazyPluginSpec
return {
  "laytan/cloak.nvim",
  event = "LazyFile",
  cmd = { "CloakEnable", "CloakDisable", "CloakToggle" },
  keys = core.lazy_map({
    n = {
      ["<leader>ct"] = {
        function()
          require("cloak").toggle()
        end,
        "Cloak: Toggle",
      },
    },
  }),
  opts = {},
}
