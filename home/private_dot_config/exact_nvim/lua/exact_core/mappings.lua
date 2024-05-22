--------------------------------------------------------------------------------
--  MAPPINGS
--------------------------------------------------------------------------------
---@alias core.mappings.terminal_mappings table<string, utils.mappings.mapping>
---@alias core.mappings.lsp_mappings utils.mappings.mappings_spec

---@class core.mappings
---@field mappings utils.mappings.mappings_spec
---@field mapping_opts utils.mappings.mapping_opts
---@field lsp_mappings core.mappings.lsp_mappings
---@field terminal_mappings core.mappings.terminal_mappings

---@type core.mappings
local M = {}

--------------------------------------------------------------------------------
--  LSP mappings
--------------------------------------------------------------------------------
M.lsp_mappings = {
  n = {
    ["gd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      desc = "LSP: Goto Definition",
      has = "definition",
    },
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
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
      function()
        vim.diagnostic.open_float()
      end,
      desc = "LSP: Line Diagnostics",
    },
    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      desc = "LSP: Hover",
    },
    ["]d"] = {
      function()
        vim.diagnostic.goto_next()
      end,
      desc = "LSP: Next Diagnostic",
    },
    ["[d"] = {
      function()
        vim.diagnostic.goto_prev()
      end,
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
      function()
        vim.lsp.buf.rename()
      end,
      desc = "LSP: Rename",
      has = "rename",
    },
  },
  i = {
    ["<C-k>"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      desc = "LSP: Signature Help",
      has = "signatureHelp",
    },
  },
  [{ "n", "v" }] = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      desc = "LSP: Code Action",
      has = "codeAction",
    },
    ["<leader>cc"] = {
      function()
        vim.lsp.codelens.run()
      end,
      desc = "LSP: Run Codelens",
      has = "codeLens",
    },
    ["<leader>cC"] = {
      function()
        vim.lsp.codelens.refresh()
      end,
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

M.mappings.n = {
  -- Windows
  ["<leader>wh"] = {
    "<C-W>t <C-W>K",
    desc = "Window: Change two horizontal to vertical",
  },
  ["<leader>wv"] = {
    "<C-W>t <C-W>H",
    desc = "Window: Change two vertical to horizontal",
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

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
