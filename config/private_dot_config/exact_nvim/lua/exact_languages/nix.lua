-- ╭─────────────────────────────────────────────────────────╮
-- │ Nix                                                     │
-- ╰─────────────────────────────────────────────────────────╯

return utils.is_linux()
    and utils.plugin.get_language_spec({
      lsp = {
        servers = {
          nil_ls = {
            settings = {
              ["nil"] = {
                formatting = {
                  command = { "nixfmt" },
                },
              },
            },
          },
        },
      },
      plugins = {
        { import = "lazyvim.plugins.extras.lang.nix" },
      },
    })
  or {}
