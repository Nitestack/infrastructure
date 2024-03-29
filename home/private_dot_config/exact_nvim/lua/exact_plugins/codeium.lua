---@type LazyPluginSpec
return {
  "Exafunction/codeium.vim",
  commit = "a1c3d6b369a18514d656dac149de807becacbdf7",
  build = ":Codeium Auth",
  event = "InsertEnter",
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
