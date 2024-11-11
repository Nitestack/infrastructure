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

return M
