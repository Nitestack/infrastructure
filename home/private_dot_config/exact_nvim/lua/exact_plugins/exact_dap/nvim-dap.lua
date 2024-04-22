local filetypes = { "dap-repl", "dapui_watches", "dapui_hover" }

---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    ft = filetypes,
    dependencies = {
      "williamboman/mason.nvim",
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "williamboman/mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        config = function(_, opts)
          opts.ensure_installed = utils.remove_duplicates(opts.ensure_installed or {})
          require("mason-nvim-dap").setup(opts)
        end,
      },
      {
        "rcarriga/cmp-dap",
        dependencies = "hrsh7th/nvim-cmp",
        config = function()
          require("cmp").setup.filetype(filetypes, {
            sources = {
              { name = "dap" },
            },
          })
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = "nvim-treesitter/nvim-treesitter",
        cmd = { "DapVirtualTextEnable", "DapVirtualTextDisable", "DapVirtualTextToggle", "DapVirtualTextForceRefresh" },
        ---@type nvim_dap_virtual_text_options
        opts = {
          commented = true,
        },
      },
    },
    keys = core.lazy_map({
      n = {
        [{ "<leader>dc", "<F5>" }] = {
          function()
            require("dap").continue()
          end,
          desc = "Continue",
        },
        [{ "<leader>dt", "<F17>" }] = { -- <F17> translates to Shift+F5
          function()
            require("dap").terminate()
          end,
          desc = "Terminate",
        },
        [{ "<leader>dr", "<F29>" }] = { -- <F29> translates to Ctrl+F5
          function()
            require("dap").restart_frame()
          end,
          desc = "Restart",
        },
        [{ "<leader>dp", "<F6>" }] = {
          function()
            require("dap").pause()
          end,
          desc = "Pause",
        },
        ["<leader>da"] = {
          function()
            require("dap").continue({
              before = function(config)
                local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
                config = vim.deepcopy(config)
                ---@cast args string[]
                config.args = function()
                  local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
                  return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
                end
                return config
              end,
            })
          end,
          desc = "Run with Args",
        },
        [{ "<leader>dO", "<F10>" }] = {
          function()
            require("dap").step_over()
          end,
          desc = "Step Over",
        },
        [{ "<leader>di", "<F11>" }] = {
          function()
            require("dap").step_into()
          end,
          desc = "Step Into",
        },
        [{ "<leader>do", "<F23>" }] = { -- <F23> translates to Shift+F11
          function()
            require("dap").step_out()
          end,
          desc = "Step Out",
        },
        ["<leader>dq"] = {
          function()
            require("dap").close()
          end,
          desc = "Close",
        },
        ["<leader>ds"] = {
          function()
            require("dap").run_to_cursor()
          end,
          desc = "Run to Cursor",
        },
        ["<leader>dg"] = {
          function()
            require("dap").goto_()
          end,
          desc = "Go to Line (No Execute)",
        },
        ["<leader>dj"] = {
          function()
            require("dap").down()
          end,
          desc = "Down",
        },
        ["<leader>dk"] = {
          function()
            require("dap").up()
          end,
          desc = "Up",
        },
        ["<leader>dl"] = {
          function()
            require("dap").run_last()
          end,
          desc = "Run Last",
        },
        ["<leader>dR"] = {
          function()
            require("dap").repl.toggle()
          end,
          desc = "Toggle REPL",
        },
        ["<leader>dw"] = {
          function()
            require("dap.ui.widgets").hover()
          end,
          desc = "Widgets",
        },
      },
    }),
    config = function()
      ---@type table<string, vim.fn.sign_define.dict>
      local dap_signs = {
        DapBreakpoint = {
          text = core.icons.dap.Breakpoint,
          texthl = "DapBreakpoint",
          linehl = "",
          numhl = "",
        },
        DapBreakpointCondition = {
          text = core.icons.dap.BreakpointCondition,
          texthl = "DapBreakpointCondition",
          linehl = "",
          numhl = "",
        },
        DapBreakpointRejected = {
          text = core.icons.dap.BreakpointRejected,
          texthl = "DapBreakpointRejected",
          linehl = "",
          numhl = "",
        },
        DapLogPoint = {
          text = core.icons.dap.LogPoint,
          texthl = "DapLogPoint",
          linehl = "",
          numhl = "",
        },
        DapStopped = {
          text = core.icons.dap.Stopped,
          texthl = "DapStopped",
          linehl = "Visual",
          numhl = "",
        },
      }
      for name, dict in pairs(dap_signs) do
        vim.fn.sign_define(name, dict)
      end
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      defaults = {
        ["<leader>d"] = { name = "Debugging" },
      },
    },
  },
}
