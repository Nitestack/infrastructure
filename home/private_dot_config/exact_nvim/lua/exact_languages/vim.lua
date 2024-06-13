-- ╭─────────────────────────────────────────────────────────╮
-- │ Vim                                                     │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  treesitter = {
    "vim",
    "vimdoc",
  },
  mason = {
    "vim-language-server",
    "vint",
  },
  lsp = {
    servers = {
      vimls = {},
    },
  },
  linter = {
    linters_by_ft = {
      ["vim"] = { "vint" },
    },
  },
})
