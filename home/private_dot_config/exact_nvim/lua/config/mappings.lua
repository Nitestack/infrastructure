--------------------------------------------------------------------------------
--  MAPPINGS & UNMAPPINGS
--------------------------------------------------------------------------------

---@class MappingsConfig
---@field lsp_mappings fun(args):Mappings
---@field terminal_mappings KeymapConfig
---@field mappings Mappings
---@field unmappings DisableMappings
---@field mapping_opts KeymapOpts

---@type MappingsConfig
local M = {}

--------------------------------------------------------------------------------
--  LSP mappings
--------------------------------------------------------------------------------
function M.lsp_mappings()
  return {
    n = {
      ["gd"] = {
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end,
        "Goto Definition",
        has = "definition",
      },
      ["gD"] = {
        vim.lsp.buf.declaration,
        "Goto Declaration",
      },
      ["gr"] = {
        require("telescope.builtin").lsp_references,
        "References",
      },
      ["gi"] = {
        function()
          require("telescope.builtin").lsp_implementations({ reuse_win = true })
        end,
        "Goto Implementation",
      },
      ["go"] = {
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
        end,
        "Goto Type Definition",
      },
      ["<leader>cd"] = {
        vim.diagnostic.open_float,
        "Line Diagnostics",
      },
      ["K"] = {
        vim.lsp.buf.hover,
        "Hover",
      },
      ["]d"] = {
        vim.diagnostic.goto_next,
        "Next Diagnostic",
      },
      ["[d"] = {
        vim.diagnostic.goto_prev,
        "Prev Diagnostic",
      },
      ["]e"] = {
        function()
          vim.diagnostic.goto_next({
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        "Next Error",
      },
      ["[e"] = {
        function()
          vim.diagnostic.goto_prev({
            severity = vim.diagnostic.severity.ERROR,
          })
        end,
        "Prev Error",
      },
      ["]w"] = {
        function()
          vim.diagnostic.goto_next({
            severity = vim.diagnostic.severity.WARN,
          })
        end,
        "Next Warning",
      },
      ["[w"] = {
        function()
          vim.diagnostic.goto_prev({
            severity = vim.diagnostic.severity.WARN,
          })
        end,
        "Prev Warning",
      },
      ["<leader>cA"] = {
        function()
          vim.lsp.buf.code_action({
            context = {
              only = {
                "source",
              },
              diagnostics = {},
            },
          })
        end,
        "Source Action",
        has = "codeAction",
      },
      [{ "<leader>cr", "<F2>" }] = {
        vim.lsp.buf.rename,
        "Rename",
        has = "rename",
      },
    },
    i = {
      ["<C-k>"] = {
        vim.lsp.buf.signature_help,
        "Signature Help",
        has = "signatureHelp",
      },
    },
    [{ "n", "v" }] = {
      ["<leader>ca"] = {
        function()
          require("lazy").load({ plugins = { "actions-preview.nvim" } })
          require("actions-preview").code_actions()
        end,
        "Code Action",
        has = "codeAction",
      },
    },
  }
end

--------------------------------------------------------------------------------
--  Terminal mappings
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
--  Mappings
--------------------------------------------------------------------------------
M.mappings = {}

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
