local filetypes = { "dap-repl", "dapui_watches", "dapui_hover" }
local load_breakpoints_event = { "BufReadPost" }

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
    "Weissle/persistent-breakpoints.nvim",
    event = load_breakpoints_event,
    cmd = {
      "PBToggleBreakpoint",
      "PBSetConditionalBreakpoint",
      "PBClearAllBreakpoints",
      "PBReload",
      "PBStore",
      "PBLoad",
    },
    keys = core.lazy_map({
      n = {
        [{ "<leader>db", "<F9>" }] = {
          function()
            require("persistent-breakpoints.api").toggle_breakpoint()
          end,
          desc = "Toggle Breakpoint",
        },
        ["<leader>dB"] = {
          function()
            require("persistent-breakpoints.api").clear_all_breakpoints()
          end,
          desc = "Clear Breakpoints",
        },
        [{ "<leader>dC", "<F21>" }] = { -- <F21> translates to Shift+F9
          function()
            require("persistent-breakpoints.api").set_conditional_breakpoint()
          end,
          desc = "Set Breakpoint Condition",
        },
      },
    }),
    opts = {
      load_breakpoints_event = load_breakpoints_event,
    },
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
    ---@type nvim_dap_virtual_text_options
    opts = {
      commented = true,
    },
  },
}, {
  which_key = {
    ["<leader>d"] = "Debugging",
  },
})
