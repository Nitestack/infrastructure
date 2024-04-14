---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ---@type neotest.Config
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      ---@type LanguageTestConfig
      adapters = {},
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          require("trouble").open({ mode = "quickfix", focus = false })
        end,
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, vim.api.nvim_create_namespace("neotest"))

      opts.consumers = opts.consumers or {}
      -- Refresh and auto close trouble after running tests
      ---@type neotest.Consumer
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local trouble = require("trouble")
            if trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
          return {}
        end
      end

      local adapters = {}
      for name, config in pairs(opts.adapters) do
        if config ~= false then
          local adapter = require(name)
          if type(config) == "table" and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)
            if adapter.setup then
              adapter.setup(config)
            elseif meta and meta.__call then
              adapter(config)
            else
              error("Adapter " .. name .. " does not support setup")
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end
      opts.adapters = adapters

      require("neotest").setup(opts)
    end,
    keys = core.lazy_map({
      n = {
        ["<leader>tt"] = {
          function()
            require("neotest").run.run(vim.fn.expand("%"))
          end,
          "Run File",
        },
        ["<leader>tT"] = {
          function()
            require("neotest").run.run(vim.uv.cwd())
          end,
          "Run All Test Files",
        },
        ["<leader>tr"] = {
          function()
            require("neotest").run.run()
          end,
          "Run Nearest",
        },
        ["<leader>tl"] = {
          function()
            require("neotest").run.run_last()
          end,
          "Run Last",
        },
        ["<leader>ts"] = {
          function()
            require("neotest").summary.toggle()
          end,
          "Toggle Summary",
        },
        ["<leader>to"] = {
          function()
            require("neotest").output.open({ enter = true, auto_close = true })
          end,
          "Show Output",
        },
        ["<leader>tO"] = {
          function()
            require("neotest").output_panel.toggle()
          end,
          "Toggle Output Panel",
        },
        ["<leader>tS"] = {
          function()
            require("neotest").run.stop()
          end,
          "Stop",
        },
      },
    }),
  },
  {
    "mfussenegger/nvim-dap",
    keys = core.lazy_map({
      n = {
        ["<leader>td"] = {
          function()
            require("neotest").run.run({ strategy = "dap" })
          end,
          "Debug Nearest",
        },
      },
    }),
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      defaults = {
        ["<leader>t"] = { name = "+test" },
      },
    },
  },
}
