---@type LazyPluginSpec
return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "mfussenegger/nvim-dap",
  },
  keys = core.lazy_map({
    n = {
      ["u"] = {
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI",
      },
      ["e"] = {
        function()
          vim.ui.input({ prompt = "Expression: " }, function(expr)
            if expr then
              require("dapui").eval(expr, { enter = true })
            end
          end)
        end,
        desc = "Evaluate Input",
      },
    },
    v = {
      ["e"] = {
        function()
          require("dapui").eval()
        end,
        desc = "Eval",
      },
    },
  }, {
    prefix = "<leader>d",
  }),
  opts = {
    floating = {
      border = core.config.ui.transparent.floats and "rounded" or "none",
    },
  },
  config = function(_, opts)
    -- Setup DAP config by VSCode `launch.json` file
    -- require("dap.ext.vscode").load_launchjs()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup(opts)

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
