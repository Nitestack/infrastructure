local settings = require("core.settings")

for k, v in pairs(settings.options) do
  vim.opt[k] = v
end

for k, v in pairs(settings.globals) do
  vim.g[k] = v
end

for _, provider in ipairs(settings.disabled_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

settings.run()

vim.filetype.add(require("core.filetypes"))
