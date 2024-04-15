--------------------------------------------------------------------------------
--  PowerShell
--------------------------------------------------------------------------------
return utils.plugin.get_language_spec({
  mason = {
    "powershell-editor-services",
  },
  lsp = {
    servers = {
      powershell_es = {},
    },
  },
})
