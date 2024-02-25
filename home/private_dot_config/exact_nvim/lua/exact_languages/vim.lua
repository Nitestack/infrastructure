--------------------------------------------------------------------------------
--  Vim
--------------------------------------------------------------------------------
return core.load_language({
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
