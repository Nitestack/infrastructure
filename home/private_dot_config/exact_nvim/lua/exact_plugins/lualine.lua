local function get_fg(name)
  ---@type {foreground?:number}?
  ---@diagnostic disable-next-line: deprecated
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  ---@diagnostic disable-next-line: undefined-field
  local fg = hl and (hl.fg or hl.foreground)
  return fg and { fg = string.format("#%06x", fg) } or nil
end

local window_width_limit = 100
local function hide_in_width()
  return vim.o.columns > window_width_limit
end

---@type LazyPluginSpec
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    return {
      options = {
        theme = core.config.ui.theme,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "dashboard" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "b:gitsigns_head",
            icon = core.icons.git.Branch,
            color = { gui = "bold" },
          },
        },
        lualine_c = {
          {
            "diff",
            symbols = {
              added = core.icons.git.LineAdded .. " ",
              modified = core.icons.git.LineModified .. " ",
              removed = core.icons.git.LineRemoved .. " ",
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
          },
        },

        lualine_x = {
          {
            function()
              return require("noice").api.status.command.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.command.has()
            end,
            color = get_fg("Statement"),
          },
          {
            function()
              return require("noice").api.status.mode.get()
            end,
            cond = function()
              return package.loaded["noice"] and require("noice").api.status.mode.has()
            end,
            color = get_fg("Constant"),
          },
          {
            function()
              return "  " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = get_fg("Debug"),
          },
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = get_fg("Special"),
          },
          {
            "diagnostics",
            symbols = {
              error = core.icons.diagnostics.Error .. " ",
              warn = core.icons.diagnostics.Warning .. " ",
              info = core.icons.diagnostics.Information .. " ",
              hint = core.icons.diagnostics.Hint .. " ",
            },
          },
          {
            function()
              local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
              if #buf_clients == 0 then
                return core.icons.ui.Lock .. " LSP Inactive"
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
              local language_servers = string.format(
                core.icons.ui.Gear .. " LSP " .. core.icons.ui.ChevronShortRight .. " %s",
                unique_client_names
              )

              if copilot_active then
                language_servers = language_servers .. "%#SLCopilot#" .. " " .. core.icons.git.Octoface .. "%*"
              end

              return language_servers
            end,
            color = { gui = "bold" },
            cond = hide_in_width,
          },
          {
            function()
              local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
              return core.icons.ui.Tab .. " " .. shiftwidth
            end,
            padding = 1,
          },
          "filetype",
        },
        lualine_y = { "location" },
        lualine_z = {
          {
            "progress",
            fmt = function()
              return "%P/%L"
            end,
          },
        },
      },
      extensions = {
        -- don't include mason in lualine
        -- lualine is loaded via the "VeryLazy" event and loading mason on startup is heavy
        "lazy",
        "man",
        "quickfix",
        "toggleterm",
        "trouble",
      },
    }
  end,
}
