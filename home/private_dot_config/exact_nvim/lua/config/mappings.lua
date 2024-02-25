--------------------------------------------------------------------------------
--  MAPPINGS & UNMAPPINGS
--------------------------------------------------------------------------------

---@class MappingsConfig
---@field mappings Mappings
---@field terminal_mappings KeymapConfig
---@field unmappings DisableMappings
---@field mapping_opts KeymapOpts

---@type MappingsConfig
local M = {}

--------------------------------------------------------------------------------
--  Mappings
--------------------------------------------------------------------------------
M.mappings = {}

M.terminal_mappings = {
  ["<Esc>"] = {
    "<C-\\><C-n>",
    "Enter Normal Mode",
  },
  ["<C-h>"] = {
    function()
      vim.cmd.wincmd("h")
    end,
    "Window left",
  },
  ["<C-j>"] = {
    function()
      vim.cmd.wincmd("j")
    end,
    "Window down",
  },
  ["<C-k>"] = {
    function()
      vim.cmd.wincmd("k")
    end,
    "Window up",
  },
  ["<C-l>"] = {
    function()
      vim.cmd.wincmd("l")
    end,
    "Window right",
  },
}

-- Delete into void register
M.mappings[{ "n", "v" }] = {
  ["<leader>d"] = {
    [["_d]],
    "Delete into void register",
  },
}

-- Move around wrapped lines
M.mappings[{ "n", "x" }] = {
  [{ "j", "<Down>" }] = {
    "v:count == 0 ? 'gj' : 'j'",
    "Move down",
    opts = {
      expr = true,
    },
  },
  [{ "k", "<Up>" }] = {
    "v:count == 0 ? 'gk' : 'k'",
    "Move up",
    opts = {
      expr = true,
    },
  },
}

M.mappings.n = {
  -- Windows
  ["<C-h>"] = {
    "<C-W>h",
    "Window left",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-j>"] = {
    "<C-W>j",
    "Window down",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-k>"] = {
    "<C-W>k",
    "Window up",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-l>"] = {
    "<C-W>l",
    "Window right",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-Up>"] = {
    function()
      vim.cmd("resize +2")
    end,
    "Increase window height",
  },
  ["<C-Down>"] = {
    function()
      vim.cmd("resize -2")
    end,
    "Decrease window height",
  },
  ["<C-Left>"] = {
    function()
      vim.cmd("vertical resize -2")
    end,
    "Decrease window width",
  },
  ["<C-Right>"] = {
    function()
      vim.cmd("vertical resize +2")
    end,
    "Increase window width",
  },
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    "Change two horizontal windows to vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    "Change two vertical windows to horizontal",
  },
  -- Quotes
  ["<leader>\""] = {
    [[ciw"<c-r>""<esc>]],
    "Surround with double quotes",
  },
  ["<leader>'"] = {
    [[ciw'<c-r>"'<esc>]],
    "Surround with single quotes",
  },
  ["<leader>`"] = {
    [[ciw`<c-r>"`<esc>]],
    "Surround with backticks",
  },
  ["<leader>)"] = {
    [[ciw(<c-r>")<esc>]],
    "Surround with parentheses",
  },
  ["<leader>}"] = {
    [[ciw{<c-r>"}<esc>]],
    "Surround with braces",
  },
  -- Clear hlsearch with <ESC>
  ["<ESC>"] = {
    "<cmd>noh<cr><esc>",
    "Escape and clear hlsearch",
  },
  -- Quit
  ["<leader>qq"] = {
    vim.cmd.qa,
    "Quit all",
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
    "Delete line",
    opts = {
      expr = true,
      silent = true,
    },
  },
  -- General
  ["x"] = { "\"_x" },
  ["<leader>l"] = {
    function()
      vim.cmd("Lazy")
    end,
    "Lazy",
  },
}

if not core.is_win() then
  -- Make file executable
  M.mappings.n["<leader>cx"] = {
    function()
      vim.cmd("!chmod +x %")
    end,
    "Make file executable",
  }
end

M.mappings.v = {
  -- Jump back
  ["<BS>"] = {
    "<C-o>",
    "Jump back",
  },
  -- Indent
  ["<Tab>"] = {
    ">gv",
    "Indent right",
  },
  ["<S-Tab>"] = {
    "<gv",
    "Indent left",
  },
  -- Quotes
  ["<leader>\""] = {
    [[c"<c-r>""<esc>]],
    "Surround selection with double quotes",
  },
  ["<leader>'"] = {
    [[c'<c-r>"'<esc>]],
    "Surround selection with single quotes",
  },
  ["<leader>`"] = {
    [[c`<c-r>"`<esc>]],
    "Surround selection with backticks",
  },
  ["<leader>)"] = {
    [[c(<c-r>")<esc>]],
    "Surround selection with parentheses",
  },
  ["<leader>}"] = {
    [[c{<c-r>"}<esc>]],
    "Surround selection with braces",
  },
  -- End of line
  ["$"] = {
    "g_",
    "End of line (ignore whitespace)",
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
    "Execute macro over visual range",
    opts = {
      silent = false,
    },
  },
}

-- Save file
-- M.mappings[{ "i", "x", "n", "s" }] = {
--   ["<C-s>"] = {
--     "<cmd>w<cr><esc>",
--     "Save file",
--   },
-- }

--------------------------------------------------------------------------------
--  Unmappings
--------------------------------------------------------------------------------
M.unmappings = {}

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
