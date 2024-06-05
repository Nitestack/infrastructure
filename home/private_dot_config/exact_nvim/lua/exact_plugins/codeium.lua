---@type LazyPluginSpec
return {
  "Exafunction/codeium.vim",
  cmd = "Codeium",
  build = ":Codeium Auth",
  event = "InsertEnter",
  keys = core.lazy_map({
    i = {
      ["<M-Enter>"] = {
        function()
          return vim.fn["codeium#Accept"]()
        end,
        desc = "Accept Codium suggestion",
        silent = true,
        expr = true,
      },
    },
  }),
}
