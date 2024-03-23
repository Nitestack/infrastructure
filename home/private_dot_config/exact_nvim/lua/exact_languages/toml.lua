return core.load_language({
  mason = {
    "taplo",
  },
  lsp = {
    servers = {
      taplo = {
        keys = {
          {
            "K",
            function()
              if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                require("crates").show_popup()
              else
                vim.lsp.buf.hover()
              end
            end,
            "Show Crate Documentation",
          },
        },
      },
    }
  }
})

