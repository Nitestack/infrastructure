local M = {}

local icons = require("config.icons")
local window_width_limit = 100

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

M.gitsigns = {
  "b:gitsigns_head",
  icon = icons.git.Branch,
  color = { gui = "bold" },
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
}

M.command_status = {
  function()
    return require("noice").api.status.command.get()
  end,
  cond = function()
    return package.loaded["noice"] and require("noice").api.status.command.has()
  end,
  color = get_fg("Statement"),
}

M.mode_status = {
  function()
    return require("noice").api.status.mode.get()
  end,
  cond = function()
    return package.loaded["noice"] and require("noice").api.status.mode.has()
  end,
  color = get_fg("Constant"),
}

M.debug_status = {
  function()
    return "  " .. require("dap").status()
  end,
  cond = function()
    return package.loaded["dap"] and require("dap").status() ~= ""
  end,
  color = get_fg("Debug"),
}

M.lazy_updates = {
  require("lazy.status").updates,
  cond = require("lazy.status").has_updates,
  color = get_fg("Special"),
}

M.diagnostics = {
  "diagnostics",
  symbols = {
    error = icons.diagnostics.Error .. " ",
    warn = icons.diagnostics.Warning .. " ",
    info = icons.diagnostics.Information .. " ",
    hint = icons.diagnostics.Hint .. " ",
  },
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
  padding = 1,
}

M.filetype = {
  "filetype",
  color = { gui = "bold" },
}

M.progress = {
  "progress",
  fmt = function()
    return "%P/%L"
  end,
}

return M
