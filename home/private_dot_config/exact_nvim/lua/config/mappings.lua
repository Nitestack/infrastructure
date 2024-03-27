--------------------------------------------------------------------------------
--  MAPPINGS & UNMAPPINGS
--------------------------------------------------------------------------------

---@class MappingsConfig
---@field lsp_mappings fun(args):Mappings
---@field terminal_mappings KeymapConfig
---@field mappings Mappings
---@field unmappings DisableMappings
---@field mapping_opts KeymapOpts

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3

---@type MappingsConfig
local M = {}

--------------------------------------------------------------------------------
--  LSP mappings
--------------------------------------------------------------------------------
function M.lsp_mappings()
  return {
    n = {
      ["gd"] = {
        vim.lsp.buf.definition,
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
      ["gI"] = {
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
        vim.lsp.buf.code_action,
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
  ["<C-h>"] = {
    "<C-W>h",
    "Window: Select left",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-j>"] = {
    "<C-W>j",
    "Window: Select lower",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-k>"] = {
    "<C-W>k",
    "Window: Select upper",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-l>"] = {
    "<C-W>l",
    "Window: Select right",
    opts = {
      noremap = false,
      remap = true,
    },
  },
  ["<C-Up>"] = {
    function()
      vim.cmd("resize +2")
    end,
    "Window: Increase height",
  },
  ["<C-Down>"] = {
    function()
      vim.cmd("resize -2")
    end,
    "Window: Decrease height",
  },
  ["<C-Left>"] = {
    function()
      vim.cmd("vertical resize -2")
    end,
    "Window: Decrease width",
  },
  ["<C-Right>"] = {
    function()
      vim.cmd("vertical resize +2")
    end,
    "Window: Increase width",
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
      require("utils.toggle").diagnostics()
    end,
    "Diagnostics: Toggle",
  },
  ["<leader>uh"] = {
    function()
      require("utils.toggle").inlay_hints()
    end,
    "Inlay Hints: Toggle",
  },
  ["<leader>ut"] = {
    function()
      if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end
    end,
    "Treesitter: Toggle",
  },
  ["<leader>uc"] = {
    function()
      require("utils.toggle").option("conceallevel", false, { 0, conceallevel })
    end,
    "Conceal: Toggle",
  },
  ["<leader>us"] = {
    function()
      require("utils.toggle").option("spell")
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

--------------------------------------------------------------------------------
--  Unmappings
--------------------------------------------------------------------------------
M.unmappings = {}

M.mapping_opts = {
  silent = true,
  noremap = true,
}

return M
