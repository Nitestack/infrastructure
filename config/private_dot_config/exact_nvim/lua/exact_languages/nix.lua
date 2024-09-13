-- ╭─────────────────────────────────────────────────────────╮
-- │ Nix                                                     │
-- ╰─────────────────────────────────────────────────────────╯

return utils.plugin.get_language_spec({
  plugins = {
    { import = "lazyvim.plugins.extras.lang.nix" },
  },
})
