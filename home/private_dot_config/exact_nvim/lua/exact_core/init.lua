--------------------------------------------------------------------------------
--  CONFIG
--------------------------------------------------------------------------------
---@class core
---@field cmds core.cmds
---@field config core.config
---@field filetypes core.filetypes
---@field icons core.icons
---@field mappings core.mappings
---@field settings core.settings
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("core." .. k)
    return t[k]
  end,
})

return M
