---@type LazyPluginSpec
return {
  "Exafunction/codeium.vim",
  cmd = "Codeium",
  build = ":Codeium Auth",
  event = "BufEnter",
  keys = core.lazy_map({
    i = {
      ["<M-Enter>"] = {
        function()
          return vim.fn["codeium#Accept"]()
        end,
        "Accept Codium suggestion",
        opts = {
          silent = true,
          expr = true,
        },
      },
    },
  }),
}
