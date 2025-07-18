-- ╭─────────────────────────────────────────────────────────╮
-- │ Nix                                                     │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  lsp = {
    servers = {
      nil_ls = {
        enabled = false,
      },
      nixd = {
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      },
    },
  },
  linter = {
    linters_by_ft = {
      ["nix"] = { "nix" },
    },
  },
  plugins = {
    { import = "lazyvim.plugins.extras.lang.nix" },
  },
})
