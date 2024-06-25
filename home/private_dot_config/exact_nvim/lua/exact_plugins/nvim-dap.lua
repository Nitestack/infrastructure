local filetypes = { "dap-repl", "dapui_watches", "dapui_hover" }

return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.dap.core" },
  {
    "mfussenegger/nvim-dap",
    ft = filetypes,
    dependencies = {
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
    },
    keys = core.lazy_map({
      [{ "n", "v" }] = {
        ["<leader>d"] = "Debug",
      },
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
        [{ "<leader>db", "<F9>" }] = {
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "Toggle Breakpoint",
        },
        ["<leader>dB"] = {
          function()
            require("dap").clear_breakpoints()
          end,
          desc = "Clear Breakpoints",
        },
        [{ "<leader>dC", "<F21>" }] = { -- <F21> translates to Shift+F9
          function()
            require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
          end,
          desc = "Set Breakpoint Condition",
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
        ["<leader>dR"] = {
          function()
            require("dap").repl.toggle()
          end,
          desc = "Toggle REPL",
        },
      },
    }),
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "LiadOz/nvim-dap-repl-highlights",
      ft = "dap-repl",
      opts = {},
    },
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed, { "dap_repl" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    ---@module "dapui"
    ---@type dapui.Config
    opts = {
      floating = {
        border = core.config.ui.transparent.floats and "rounded" or "none",
      },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    cmd = {
      "DapVirtualTextEnable",
      "DapVirtualTextDisable",
      "DapVirtualTextToggle",
      "DapVirtualTextForceRefresh",
    },
    ---@module "nvim-dap-virtual-text"
    ---@type nvim_dap_virtual_text_options
    opts = {
      commented = true,
    },
  },
}, {
  lualine = "nvim-dap-ui",
  catppuccin = {
    dap = true,
    dap_ui = true,
  },
})
