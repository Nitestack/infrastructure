-- ╭─────────────────────────────────────────────────────────╮
-- │ PowerShell                                              │
-- ╰─────────────────────────────────────────────────────────╯

return utils.is_win()
    and utils.plugin.get_language_spec({
      mason = {
        "powershell-editor-services",
      },
      lsp = {
        servers = {
          powershell_es = {},
        },
      },
    })
  or {}
