--------------------------------------------------------------------------------
--  PowerShell
--------------------------------------------------------------------------------
return core.load_language({
  mason = {
    "powershell-editor-services",
  },
  lsp = {
    servers = {
      powershell_es = {},
    },
  },
})
