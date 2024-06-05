--------------------------------------------------------------------------------
--  OPTIONS
--------------------------------------------------------------------------------
for option, val in pairs(core.settings.options) do
  vim.opt[option] = val
end

core.settings.run()

for global, val in pairs(core.settings.globals) do
  vim.g[global] = val
end

for _, provider in ipairs(core.settings.disabled_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end
