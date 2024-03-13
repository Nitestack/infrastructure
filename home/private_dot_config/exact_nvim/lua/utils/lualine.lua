--------------------------------------------------------------------------------
--  LUALINE COMPONENTS
--------------------------------------------------------------------------------
local M = {}

local icons = require("config.icons")
local window_width_limit = 100

---@param name string
local function get_fg(name)
  ---@type {foreground?:number}?
  ---@diagnostic disable-next-line: deprecated
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  ---@diagnostic disable-next-line: undefined-field
  local fg = hl and (hl.fg or hl.foreground)
  return fg and { fg = string.format("#%06x", fg) } or nil
end

local function hide_in_width()
  return vim.o.columns > window_width_limit
end

local function min_width(min_width_limit)
  return function()
    return vim.o.columns > min_width_limit
  end
end

---@param fun fun(C: CtpColors<string>, section: string):{ fg?:string, bg?:string, gui?:string }
local function color(fun)
  local C = require("catppuccin.palettes").get_palette()
  return function(section)
    return fun(C, section)
  end
end

M.mode = {
  "mode",
  fmt = function()
    return ""
  end,
  padding = 0,
  separator = { right = "", left = "" },
}

M.gitsigns = {
  "b:gitsigns_head",
  icon = icons.git.Branch,
  color = { gui = "bold" },
  padding = { left = 1, right = 0 },
  separator = { right = "", left = "" },
}

M.diff = {
  "diff",
  symbols = {
    added = icons.git.LineAdded .. " ",
    modified = icons.git.LineModified .. " ",
    removed = icons.git.LineRemoved .. " ",
  },
  source = function()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
      return {
        added = gitsigns.added,
        modified = gitsigns.changed,
        removed = gitsigns.removed,
      }
    end
  end,
  padding = { left = 2, right = 0 },
  separator = { right = "", left = "" },
  cond = min_width(80),
}

M.command_status = {
  function()
    return require("noice").api.status.command.get()
  end,
  cond = function()
    return package.loaded["noice"] and require("noice").api.status.command.has()
  end,
  padding = 0,
  separator = { right = " ", left = " " },
  color = color(function(C)
    return vim.tbl_extend("force", get_fg("Statement"), { bg = C.surface1 })
  end),
}

M.mode_status = {
  function()
    return require("noice").api.status.mode.get()
  end,
  cond = function()
    return package.loaded["noice"] and require("noice").api.status.mode.has() and hide_in_width()
  end,
  color = get_fg("Constant"),
}

M.debug_status = {
  function()
    return "  " .. require("dap").status()
  end,
  cond = function()
    return package.loaded["dap"] and require("dap").status() ~= "" and min_width(80)()
  end,
  color = get_fg("Debug"),
}

M.lazy_updates = {
  require("lazy.status").updates,
  cond = function()
    return require("lazy.status").has_updates() and hide_in_width()
  end,
  color = get_fg("Special"),
}

M.diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = {
    error = icons.diagnostics.Error .. " ",
    warn = icons.diagnostics.Warning .. " ",
    info = icons.diagnostics.Information .. " ",
    hint = icons.diagnostics.Hint .. " ",
  },
  update_in_insert = not core.config.performance_mode,
  padding = 0,
  separator = { right = " ", left = " " },
  color = color(function(C)
    return { bg = C.surface0 }
  end),
}

M.lsp_status = {
  function()
    local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #buf_clients == 0 then
      return icons.ui.Lock .. " LSP Inactive"
    end

    local buf_client_names = {}
    local copilot_active = false

    -- add client
    for _, client in pairs(buf_clients) do
      if client.name ~= "null-ls" and client.name ~= "copilot" then
        table.insert(buf_client_names, client.name)
      end

      if client.name == "copilot" then
        copilot_active = true
      end
    end

    local unique_client_names = table.concat(buf_client_names, ", ")
    local language_servers =
      string.format(icons.ui.Gear .. " LSP " .. icons.ui.ChevronShortRight .. " %s", unique_client_names)

    if copilot_active then
      language_servers = language_servers .. "%#SLCopilot#" .. " " .. icons.git.Octoface .. "%*"
    end

    return language_servers
  end,
  cond = hide_in_width,
}

M.shift_width = {
  function()
    local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
    return icons.ui.Tab .. " " .. shiftwidth
  end,
  cond = min_width(60),
}

M.location = {
  "location",
  separator = { left = " " },
  cond = min_width(60),
}

M.progress = {
  "progress",
  fmt = function()
    return "%P/%L"
  end,
  padding = 0,
  separator = { right = "", left = "" },
  cond = min_width(60),
}

return M
