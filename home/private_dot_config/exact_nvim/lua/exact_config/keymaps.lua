--------------------------------------------------------------------------------
--  KEYMAPS
--------------------------------------------------------------------------------
core.map(core.mappings.mappings, core.mappings.mapping_opts)

for modes, mode_keymaps in pairs(core.mappings.disabled_mappings) do
  for _, keymap in ipairs(mode_keymaps) do
    vim.keymap.del(modes, keymap)
  end
end
