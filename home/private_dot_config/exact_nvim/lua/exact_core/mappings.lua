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
      desc = "LSP: Goto Definition",
      has = "definition",
    },
    ["gD"] = {
      vim.lsp.buf.declaration,
      desc = "LSP: Goto Declaration",
    },
    ["gr"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_references()
      end,
      desc = "LSP: References",
    },
    ["gI"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_implementations({ reuse_win = true })
      end,
      desc = "LSP: Goto Implementation",
    },
    ["go"] = {
      function()
        require("lazy").load({ plugins = { "telescope.nvim" } })
        require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
      end,
      desc = "LSP: Goto Type Definition",
    },
    ["<leader>xl"] = {
      vim.diagnostic.open_float,
      desc = "LSP: Line Diagnostics",
    },
    ["K"] = {
      vim.lsp.buf.hover,
      desc = "LSP: Hover",
    },
    ["]d"] = {
      vim.diagnostic.goto_next,
      desc = "LSP: Next Diagnostic",
    },
    ["[d"] = {
      vim.diagnostic.goto_prev,
      desc = "LSP: Prev Diagnostic",
    },
    ["]e"] = {
      function()
        vim.diagnostic.goto_next({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      desc = "LSP: Next Error",
    },
    ["[e"] = {
      function()
        vim.diagnostic.goto_prev({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      desc = "LSP: Prev Error",
    },
    ["]w"] = {
      function()
        vim.diagnostic.goto_next({
          severity = vim.diagnostic.severity.WARN,
        })
      end,
      desc = "LSP: Next Warning",
    },
    ["[w"] = {
      function()
        vim.diagnostic.goto_prev({
          severity = vim.diagnostic.severity.WARN,
        })
      end,
      desc = "LSP: Prev Warning",
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
      desc = "LSP: Source Action",
      has = "codeAction",
    },
    [{ "<leader>cr", "<F2>" }] = {
      vim.lsp.buf.rename,
      desc = "LSP: Rename",
      has = "rename",
    },
  },
  i = {
    ["<C-k>"] = {
      vim.lsp.buf.signature_help,
      desc = "LSP: Signature Help",
      has = "signatureHelp",
    },
  },
  [{ "n", "v" }] = {
    ["<leader>ca"] = {
      vim.lsp.buf.code_action,
      desc = "LSP: Code Action",
      has = "codeAction",
    },
    ["<leader>cc"] = {
      vim.lsp.codelens.run,
      desc = "LSP: Run Codelens",
      has = "codeLens",
    },
    ["<leader>cC"] = {
      vim.lsp.codelens.refresh,
      desc = "LSP: Refresh Codelens",
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
    desc = "Enter Normal Mode",
  },
  ["<C-h>"] = {
    function()
      vim.cmd.wincmd("h")
    end,
    desc = "Window left",
  },
  ["<C-j>"] = {
    function()
      vim.cmd.wincmd("j")
    end,
    desc = "Window down",
  },
  ["<C-k>"] = {
    function()
      vim.cmd.wincmd("k")
    end,
    desc = "Window up",
  },
  ["<C-l>"] = {
    function()
      vim.cmd.wincmd("l")
    end,
    desc = "Window right",
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
    desc = "Delete without copying into register",
  },
}

-- Move around wrapped lines
M.mappings[{ "n", "x" }] = {
  [{ "j", "<Down>" }] = {
    "v:count == 0 ? 'gj' : 'j'",
    desc = "Move down",
    expr = true,
  },
  [{ "k", "<Up>" }] = {
    "v:count == 0 ? 'gk' : 'k'",
    desc = "Move up",
    expr = true,
  },
}

M.mappings.n = {
  -- Windows
  [{ "<leader>-", "<leader>w-" }] = {
    "<C-W>s",
    desc = "Window: Split below",
    noremap = false,
    remap = true,
  },
  [{ "<leader>|", "<leader>w|" }] = {
    "<C-W>v",
    desc = "Window: Split right",
    noremap = false,
    remap = true,
  },
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    desc = "Window: Change two horizontal to vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    desc = "Window: Change two vertical to horizontal",
  },
  -- Smarter search jumping
  ["n"] = {
    "'Nn'[v:searchforward].'zv'",
    desc = "Next search match",
    expr = true,
  },
  ["N"] = {
    "'nN'[v:searchforward].'zv'",
    desc = "Previous search match",
    expr = true,
  },
  -- Clear hlsearch with <ESC>
  ["<ESC>"] = {
    "<cmd>noh<cr><esc>",
    desc = "Escape and clear hlsearch",
  },
  -- Quit
  ["<leader>qq"] = {
    vim.cmd.qa,
    desc = "Quit all",
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
  -- Toggle UI
  ["<leader>ud"] = {
    function()
      utils.toggle.diagnostics()
    end,
    desc = "Diagnostics: Toggle",
  },
  ["<leader>uh"] = {
    function()
      utils.toggle.inlay_hints()
    end,
    desc = "Inlay Hints: Toggle",
  },
  ["<leader>ut"] = {
    function()
      if vim.b.ts_highlight then
        vim.treesitter.stop()
      else
        vim.treesitter.start()
      end
    end,
    desc = "Treesitter: Toggle",
  },
  ["<leader>uc"] = {
    function()
      utils.toggle("conceallevel", false, { 0, conceallevel })
    end,
    desc = "Conceal: Toggle",
  },
  ["<leader>us"] = {
    function()
      utils.toggle("spell")
    end,
    desc = "Spelling: Toggle",
  },
  -- General
  ["x"] = {
    "\"_x",
    desc = "Delete character without copying into register",
  },
  ["<leader>l"] = {
    function()
      vim.cmd("Lazy")
    end,
    desc = "Lazy",
  },
}

-- Smart search jumping
M.mappings[{ "x", "o" }] = {
  ["n"] = {
    "'Nn'[v:searchforward]",
    desc = "Next search match",
    expr = true,
  },
  ["N"] = {
    "'nN'[v:searchforward]",
    desc = "Previous search match",
    expr = true,
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

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
