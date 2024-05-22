--------------------------------------------------------------------------------
--  OPTIONS
--------------------------------------------------------------------------------
for option, val in pairs(core.settings.options) do
  vim.opt[option] = val
end

core.settings.run()
