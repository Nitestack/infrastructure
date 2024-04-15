--------------------------------------------------------------------------------
--  UTILS
--------------------------------------------------------------------------------
---@class utils: LazyUtilCore
---@field breadcrumbs utils.breadcrumbs
---@field cmds utils.cmds
---@field globals utils.globals
---@field lazyfile utils.lazyfile
---@field lsp utils.lsp
---@field lualine utils.lualine
---@field mappings utils.mappings
---@field snippet utils.snippet
---@field telescope utils.telescope
---@field toggle utils.toggle
local M = {}

setmetatable(M, {
  __index = function(t, k)
    -- Use `lazy.nvim` utils
    local LazyUtil = require("lazy.core.util")
    if LazyUtil[k] then
      return LazyUtil[k]
    end

    -- Use util modules
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

return M
