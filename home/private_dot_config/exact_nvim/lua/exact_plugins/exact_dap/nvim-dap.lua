---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "williamboman/mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          handlers = {},
        },
        config = function(_, opts)
          opts.ensure_installed = core.remove_duplicates(opts.ensure_installed or {})
          require("mason-nvim-dap").setup(opts)
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = {},
      },
    },
    keys = core.lazy_map({
      n = {
        [{ "<leader>dc", "<F5>" }] = {
          function()
            require("dap").continue()
          end,
          "Continue",
        },
        [{ "<leader>dt", "<F17>" }] = { -- <F17> translates to Shift+F5
          function()
            require("dap").terminate()
          end,
          "Terminate",
        },
        [{ "<leader>dr", "<F29>" }] = { -- <F29> translates to Ctrl+F5
          function()
            require("dap").restart_frame()
          end,
          "Restart",
        },
        [{ "<leader>dp", "<F6>" }] = {
          function()
            require("dap").pause()
          end,
          "Pause",
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
          "Run with Args",
        },
        [{ "<leader>dO", "<F10>" }] = {
          function()
            require("dap").step_over()
          end,
          "Step Over",
        },
        [{ "<leader>di", "<F11>" }] = {
          function()
            require("dap").step_into()
          end,
          "Step Into",
        },
        [{ "<leader>do", "<F23>" }] = { -- <F23> translates to Shift+F11
          function()
            require("dap").step_out()
          end,
          "Step Out",
        },
        ["<leader>dq"] = {
          function()
            require("dap").close()
          end,
          "Close",
        },
        ["<leader>ds"] = {
          function()
            require("dap").run_to_cursor()
          end,
          "Run to Cursor",
        },
        ["<leader>dg"] = {
          function()
            require("dap").goto_()
          end,
          "Go to Line (No Execute)",
        },
        ["<leader>dj"] = {
          function()
            require("dap").down()
          end,
          "Down",
        },
        ["<leader>dk"] = {
          function()
            require("dap").up()
          end,
          "Up",
        },
        ["<leader>dl"] = {
          function()
            require("dap").run_last()
          end,
          "Run Last",
        },
        ["<leader>dR"] = {
          function()
            require("dap").repl.toggle()
          end,
          "Toggle REPL",
        },
        ["<leader>dw"] = {
          function()
            require("dap.ui.widgets").hover()
          end,
          "Widgets",
        },
      },
    }),
    config = function()
      ---@type table<string, vim.fn.sign_define.dict>
      local dap_signs = {
        DapBreakpoint = {
          text = core.icons.ui.Circle,
          texthl = "DapBreakpoint",
          linehl = "",
          numhl = "",
        },
        DapBreakpointCondition = {
          text = core.icons.diagnostics.Question,
          texthl = "DapBreakpointCondition",
          linehl = "",
          numhl = "",
        },
        DapBreakpointRejected = {
          text = core.icons.diagnostics.Error,
          texthl = "DapBreakpointRejected",
          linehl = "",
          numhl = "",
        },
        DapLogPoint = {
          text = "◆",
          texthl = "DapLogPoint",
          linehl = "",
          numhl = "",
        },
        DapStopped = {
          text = core.icons.ui.BoldArrowRight,
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
