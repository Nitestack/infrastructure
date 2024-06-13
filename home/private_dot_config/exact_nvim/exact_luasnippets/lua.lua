-- ╭─────────────────────────────────────────────────────────╮
-- │ LUA SNIPPETS                                            │
-- ╰─────────────────────────────────────────────────────────╯

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
          t(""),
          sn(nil, fmt([[dependencies = {{ {} }},]], { i(1, "DEPENDENCIES") })),
          sn(nil, fmt([[dependencies = "{}",]], { i(1, "DEPENDENCY") })),
        }),
        c(3, {
          t(""),
          sn(nil, fmt([[event = "{}",]], { i(1, "EVENT") })),
          sn(nil, fmt([[event = {{ {} }},]], { i(1, "EVENTS") })),
        }),
        c(4, {
          t(""),
          t("keys = core.lazy_map({}),"),
        }),
        i(0),
      }
    )
  ),
}
