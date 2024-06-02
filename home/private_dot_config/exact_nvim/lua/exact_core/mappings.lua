--------------------------------------------------------------------------------
--  MAPPINGS
--------------------------------------------------------------------------------
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
      -- Tabs
      "<leader><tab>l",
      "<leader><tab>f",
      "<leader><tab><tab>",
      "<leader><tab>]",
      "<leader><tab>d",
      "<leader><tab>[",
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

if not utils.is_win() then
  -- Make file executable
  M.mappings.n["<leader>cx"] = {
    function()
      vim.cmd("!chmod +x %")
    end,
    desc = "Make file executable",
  }
end

M.mappings.v = {
  -- Indent
  ["<Tab>"] = {
    ">gv",
    desc = "Indent right",
  },
  ["<S-Tab>"] = {
    "<gv",
    desc = "Indent left",
  },
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
