--------------------------------------------------------------------------------
--  UTILS
--------------------------------------------------------------------------------
---@class utils
---@field breadcrumbs utils.breadcrumbs
---@field cmds utils.cmds
---@field globals utils.globals
---@field lazyfile utils.lazyfile
---@field lsp utils.lsp
---@field lualine utils.lualine
---@field mappings utils.mappings
---@field plugin utils.plugin
---@field snippet utils.snippet
---@field telescope utils.telescope
---@field toggle utils.toggle
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

return M
