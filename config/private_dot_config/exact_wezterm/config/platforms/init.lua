-- ╭─────────────────────────────────────────────────────────╮
-- │ PLATFORM CONFIG                                         │
-- ╰─────────────────────────────────────────────────────────╯

local utils = require("utils")

local M = {}

---@module "wezterm"
---@param config Config
function M.setup(config)
  -- ── UNIX ────────────────────────────────────────────────────────────
  if utils.is_mac() or utils.is_linux() then
    require("config.platforms.unix").setup(config)
  end
  -- ── macOS ───────────────────────────────────────────────────────────
  if utils.is_mac() then
    require("config.platforms.macos").setup(config)
  end
  -- ── Linux ───────────────────────────────────────────────────────────
  if utils.is_linux() then
    require("config.platforms.linux").setup(config)
  end
  -- ── Windows ─────────────────────────────────────────────────────────
  if utils.is_win() then
    require("config.platforms.windows").setup(config)
  end
end

return M
