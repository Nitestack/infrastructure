-- ╭─────────────────────────────────────────────────────────╮
-- │ MAPPINGS                                                │
-- ╰─────────────────────────────────────────────────────────╯

---@alias core.mappings.terminal_mappings table<string, utils.mappings.mapping>
---@alias core.mappings.lsp_mappings utils.mappings.mappings_spec

---@class core.mappings
---@field mappings utils.mappings.mappings_spec
---@field mapping_opts utils.mappings.mapping_opts
---@field disabled_mappings table<string|string[], string[]>

---@type core.mappings
local M = {
  mappings = {},
  mapping_opts = {
    silent = true,
    noremap = true,
  },
  disabled_mappings = {
    n = {
      -- Buffers
      "<S-h>",
      "<S-l>",
      "[b",
      "]b",
      "<leader>bb",
      "<leader>`",
      "<leader>bd",
      "<leader>bD",
      "<leader>fn",
      -- Terminal
      "<leader>ft",
      "<leader>fT",
      "<C-/>",
      "<C-_>",
    },
    t = {
      -- Terminal
      "<Esc><Esc>",
      "<C-/>",
      "<C-_>",
    },
    v = {
      -- Indenting
      "<",
      ">",
    },
    [{ "i", "x", "n", "s" }] = {
      -- Save
      "<C-s>",
    },
  },
}

-- Delete into void register
M.mappings[{ "n", "v" }] = {
  ["D"] = {
    [["_d]],
    desc = "Delete without copying into register",
  },
}

---@param cmd string
local function execute_command(cmd)
  require("toggleterm").exec(cmd, nil, nil, nil, "float")
end

M.mappings.n = {
  -- Windows
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    desc = "Horizontal to Vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    desc = "Vertical to Horizontal",
  },
  -- Smart delete line
  ["dd"] = {
    function()
      if vim.api.nvim_get_current_line():match("^%s*$") then
        return "\"_dd"
      else
        return "dd"
      end
    end,
    desc = "Delete line",
    expr = true,
    silent = true,
  },
  -- General
  ["x"] = {
    "\"_x",
    desc = "Delete character without copying into register",
  },
  -- Run buffer executable
  ["<leader>br"] = {
    function()
      local filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })

      if filetype == "sh" and vim.fn.executable("sh") == 0 then
        vim.notify("'.sh' files can only be executed on UNIX-based operating systems", vim.log.levels.ERROR)
        return
      end

      if filetype == "ps1" and vim.fn.executable("pwsh") == 0 then
        vim.notify("'.ps1' files can only be executed on Windows", vim.log.levels.ERROR)
        return
      end

      execute_command(vim.fn.expand("%:p"))
    end,
    desc = "Run script",
    ft = { "sh", "ps1" },
  },
  ["<leader>bl"] = {
    function()
      local filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })

      local current_line = vim.api.nvim_get_current_line():gsub("^%s+", ""):gsub("%s+$", "")

      if filetype == "lua" then
        vim.cmd(".lua")
      elseif (filetype == "sh" and vim.fn.executable("sh")) or (filetype == "ps1" and vim.fn.executable("pwsh")) then
        execute_command(current_line)
      end
    end,
    desc = "Run line",
    ft = { "lua", "sh", "ps1" },
  },
}

if utils.is_unix() then
  -- Make file executable
  M.mappings.n["<leader>bx"] = {
    function()
      vim.cmd("!chmod +x %")
    end,
    desc = "Make script executable",
    ft = "sh",
  }
end

M.mappings.v = {
  -- End of line
  ["$"] = {
    "g_",
    desc = "End of line (ignore whitespace)",
  },
}

M.mappings.x = {
  -- Macros
  ["@"] = {
    function()
      vim.ui.input({ prompt = "Macro Register: " }, function(reg)
        vim.cmd("'<,'>normal @" .. reg)
      end)
    end,
    desc = "Execute macro over visual range",
    silent = false,
  },
}

M.mappings.t = {
  ["<Esc>"] = {
    "<C-\\><C-n>",
    desc = "Enter Normal Mode",
  },
}

return M
