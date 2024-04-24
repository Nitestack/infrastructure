return utils.plugin.with_extensions({
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
      -- Can be a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      ---@type utils.plugin.language_config.test.adapters
      adapters = {},
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          require("trouble").open({ mode = "quickfix", focus = false })
        end,
      },
    },
    ---@param opts { adapters:utils.plugin.language_config.test.adapters }
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
          ---@diagnostic disable-next-line: redundant-return-value
          return {}
          ---@diagnostic disable-next-line: missing-return
        end
      end

      local adapters = {}
      for name, config in pairs(opts.adapters) do
        if config ~= false then
          local adapter = require(name)
          -- Call the adapter's setup function
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
        ["t"] = {
          function()
            require("neotest").run.run(vim.fn.expand("%"))
          end,
          desc = "Run File",
        },
        ["T"] = {
          function()
            require("neotest").run.run(vim.uv.cwd())
          end,
          desc = "Run All Test Files",
        },
        ["r"] = {
          function()
            require("neotest").run.run()
          end,
          desc = "Run Nearest",
        },
        ["l"] = {
          function()
            require("neotest").run.run_last()
          end,
          desc = "Run Last",
        },
        ["s"] = {
          function()
            require("neotest").summary.toggle()
          end,
          desc = "Toggle Summary",
        },
        ["o"] = {
          function()
            require("neotest").output.open({ enter = true, auto_close = true })
          end,
          desc = "Show Output",
        },
        ["O"] = {
          function()
            require("neotest").output_panel.toggle()
          end,
          desc = "Toggle Output Panel",
        },
        ["S"] = {
          function()
            require("neotest").run.stop()
          end,
          desc = "Stop",
        },
      },
    }, {
      prefix = "<leader>t",
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
          desc = "Debug Nearest",
        },
      },
    }),
  },
}, {
  which_key = {
    ["<leader>t"] = "Test",
  },
})
