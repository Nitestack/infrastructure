-- ╭─────────────────────────────────────────────────────────╮
-- │ BREADCRUMBS (credits to `LunarVim/breadcrumbs.nvim`     │
-- │ and `utilyre/barbecue.nvim`)                            │
-- ╰─────────────────────────────────────────────────────────╯

---@class utils.breadcrumbs
local M = {}

function M.str_is_empty(s)
  return s == nil or s == ""
end

function M.get_buf_option_value(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_get_option_value, opt, { buf = 0 })
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

M.winbar_filetype_exclude = {
  "NeogitCommitMessage",
  "netrw",
  "help",
  "startify",
  "dashboard",
  "lazy",
  "neo-tree",
  "neogitstatus",
  "NvimTree",
  "Trouble",
  "alpha",
  "lir",
  "Outline",
  "git",
  "spectre_panel",
  "toggleterm",
  "DressingSelect",
  "Jaq",
  "harpoon",
  "dap-repl",
  "dap-terminal",
  "dapui_console",
  "dapui_hover",
  "lab",
  "notify",
  "noice",
  "neotest-summary",
  "",
}

function M.get_filename()
  local filename = vim.fn.expand("%:t")
  local file_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.:h")

  if not M.str_is_empty(filename) then
    local file_icon = ""
    local hl_group = "WinBar"
    if M.get_buf_option_value("mod") then
      file_icon = core.icons.ui.Circle:gsub("%s+", "")
      hl_group = "BreadcrumbsModified"
    else
      local icons_ok, mini_icons = pcall(require, "mini.icons")
      if icons_ok then
        ---@diagnostic disable-next-line: cast-local-type
        file_icon, hl_group = mini_icons.get("file", utils.resolve_chezmoi_name("file", filename))
      end

      local buf_ft = vim.bo.filetype

      if buf_ft == "dapui_breakpoints" then
        file_icon = ""
      end

      if buf_ft == "dapui_stacks" then
        file_icon = ""
      end

      if buf_ft == "dapui_scopes" then
        file_icon = ""
      end

      if buf_ft == "dapui_watches" then
        file_icon = "󰂥"
      end

      if buf_ft == "dapui_console" then
        file_icon = ""
      end
    end

    local value = "%#" .. hl_group .. "#" .. file_icon .. "%* %#BreadcrumbsFile#" .. filename

    if not M.str_is_empty(file_path) and file_path ~= "." then
      local file_paths = vim.split(file_path, package.config:sub(1, 1), { trimempty = true })
      return " %#BreadcrumbsPath#"
        .. table.concat(file_paths, " " .. core.icons.ui.ChevronShortRight .. " ")
        .. " "
        .. core.icons.ui.ChevronShortRight
        .. "%* "
        .. value
        .. " "
    else
      return " " .. value
    end
  end
end

function M.get_winbar()
  -- Exclude some filetypes from winbar
  if vim.tbl_contains(M.winbar_filetype_exclude or {}, vim.bo.filetype) then
    return
  end
  local value = M.get_filename() or ""

  -- Apply winbar
  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

return M
