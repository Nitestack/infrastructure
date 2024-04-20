--------------------------------------------------------------------------------
--  MAPPINGS
--------------------------------------------------------------------------------
---@alias core.mappings.terminal_mappings table<string, utils.mappings.mapping>
---@alias core.mappings.lsp_mappings utils.mappings.mappings_spec

---@class core.mappings
---@field mappings utils.mappings.mappings_spec
---@field mapping_opts utils.mappings.mapping_opts
---@field lsp_mappings core.mappings.lsp_mappings|fun(args):core.mappings.lsp_mappings
---@field terminal_mappings core.mappings.terminal_mappings|fun(args):core.mappings.terminal_mappings

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3

---@type core.mappings
local M = {}

--------------------------------------------------------------------------------
--  LSP mappings
--------------------------------------------------------------------------------
M.lsp_mappings = {
  n = {
    ["gd"] = {
      vim.lsp.buf.definition,
      "LSP: Goto Definition",
      has = "definition",
    },
    ["gD"] = {
      vim.lsp.buf.declaration,
      "LSP: Goto Declaration",
    },
    ["gr"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_references()
      end,
      "LSP: References",
    },
    ["gI"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_implementations({ reuse_win = true })
      end,
      "LSP: Goto Implementation",
    },
    ["go"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
      end,
      "LSP: Goto Type Definition",
    },
    ["<leader>xl"] = {
      vim.diagnostic.open_float,
      "LSP: Line Diagnostics",
    },
    ["K"] = {
      vim.lsp.buf.hover,
      "LSP: Hover",
    },
    ["]d"] = {
      vim.diagnostic.goto_next,
      "LSP: Next Diagnostic",
    },
    ["[d"] = {
      vim.diagnostic.goto_prev,
      "LSP: Prev Diagnostic",
    },
    ["]e"] = {
      function()
        vim.diagnostic.goto_next({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      "LSP: Next Error",
    },
    ["[e"] = {
      function()
        vim.diagnostic.goto_prev({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      "LSP: Prev Error",
    },
    ["]w"] = {
      function()
        vim.diagnostic.goto_next({
          severity = vim.diagnostic.severity.WARN,
        })
      end,
      "LSP: Next Warning",
    },
    ["[w"] = {
      function()
        vim.diagnostic.goto_prev({
          severity = vim.diagnostic.severity.WARN,
        })
      end,
      "LSP: Prev Warning",
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
      "LSP: Source Action",
      has = "codeAction",
    },
    [{ "<leader>cr", "<F2>" }] = {
      vim.lsp.buf.rename,
      "LSP: Rename",
      has = "rename",
    },
  },
  i = {
    ["<C-k>"] = {
      vim.lsp.buf.signature_help,
      "LSP: Signature Help",
      has = "signatureHelp",
    },
  },
  [{ "n", "v" }] = {
    ["<leader>ca"] = {
      vim.lsp.buf.code_action,
      "LSP: Code Action",
      has = "codeAction",
    },
    ["<leader>cc"] = {
      vim.lsp.codelens.run,
      "LSP: Run Codelens",
      has = "codeLens",
    },
    ["<leader>cC"] = {
      vim.lsp.codelens.refresh,
      "LSP: Refresh Codelens",
      has = "codeLens",
    },
  },
}

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
  ["D"] = {
    [["_d]],
    "Delete without copying into register",
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
  [{ "<leader>-", "<leader>w-" }] = {
    "<C-W>s",
    "Window: Split below",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  [{ "<leader>|", "<leader>w|" }] = {
    "<C-W>v",
    "Window: Split right",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    "Window: Change two horizontal to vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    "Window: Change two vertical to horizontal",
  },
  -- Smarter search jumping
  ["n"] = {
    "'Nn'[v:searchforward].'zv'",
    "Next search match",
    opts = {
      expr = true,
    },
  },
  ["N"] = {
    "'nN'[v:searchforward].'zv'",
    "Previous search match",
    opts = {
      expr = true,
    },
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
  -- Toggle UI
  ["<leader>ud"] = {
    function()
      utils.toggle.diagnostics()
    end,
    "Diagnostics: Toggle",
  },
  ["<leader>uh"] = {
    function()
      utils.toggle.inlay_hints()
    end,
    "Inlay Hints: Toggle",
  },
  ["<leader>ut"] = {
    function()
      if vim.b.ts_highlight then
        vim.treesitter.stop()
      else
        vim.treesitter.start()
      end
    end,
    "Treesitter: Toggle",
  },
  ["<leader>uc"] = {
    function()
      utils.toggle("conceallevel", false, { 0, conceallevel })
    end,
    "Conceal: Toggle",
  },
  ["<leader>us"] = {
    function()
      utils.toggle("spell")
    end,
    "Spelling: Toggle",
  },
  -- General
  ["x"] = {
    "\"_x",
    "Delete character without copying into register",
  },
  ["<leader>l"] = {
    function()
      vim.cmd("Lazy")
    end,
    "Lazy",
  },
}

-- Smart search jumping
M.mappings[{ "x", "o" }] = {
  ["n"] = {
    "'Nn'[v:searchforward]",
    "Next search match",
    opts = {
      expr = true,
    },
  },
  ["N"] = {
    "'nN'[v:searchforward]",
    "Previous search match",
    opts = {
      expr = true,
    },
  },
}

if not utils.is_win() then
  -- Make file executable
  M.mappings.n["<leader>cx"] = {
    function()
      vim.cmd("!chmod +x %")
    end,
    "Make file executable",
  }
end

M.mappings.v = {
  -- Indent
  ["<Tab>"] = {
    ">gv",
    "Indent right",
  },
  ["<S-Tab>"] = {
    "<gv",
    "Indent left",
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

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
