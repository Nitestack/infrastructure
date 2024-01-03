---@diagnostic disable: undefined-global
return {
  s(
    { trig = "lps", name = "Neovim: Lazy plugin spec", desc = "Generates a Neovim Lazy plugin spec template" },
    fmt(
      [[
        ---@type LazyPluginSpec
        return {{
          "{}", 
          {} 
          {} 
          {}
          opts = {{
            {}
          }},
        }}
      ]],
      {
        d(1, function()
          return sn("", { i(1, vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r")) })
        end),
        c(2, {
          sn(nil, fmt([[dependencies = "{}",]], { i(1, "DEPENDENCY") })),
          sn(nil, fmt([[dependencies = {{ {} }},]], { i(1, "DEPENDENCIES") })),
          t(""),
        }),
        c(3, {
          sn(nil, fmt([[event = "{}",]], { i(1, "EVENT") })),
          sn(nil, fmt([[event = {{ {} }},]], { i(1, "EVENTS") })),
          t(""),
        }),
        c(4, {
          t("keys = core.lazy_map({}),"),
          t(""),
        }),
        i(0),
      }
    )
  ),
}
