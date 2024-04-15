--------------------------------------------------------------------------------
--  GlOBALS
--------------------------------------------------------------------------------
---@class utils.globals
local M = {}

M.map = require("utils.mappings").map
M.single_map = require("utils.mappings").single_map
M.lazy_map = require("utils.mappings").lazy_map
M.single_lazy_map = require("utils.mappings").single_lazy_map
M.auto_cmds = require("utils.cmds").auto_cmds
M.user_cmds = require("utils.cmds").user_cmds

return M
