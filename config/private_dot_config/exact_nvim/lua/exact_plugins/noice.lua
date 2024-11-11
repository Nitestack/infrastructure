---@diagnostic disable: assign-type-mismatch
return utils.plugin.with_extensions({
  {
    "folke/noice.nvim",
    ---@module "noice"
    ---@param opts NoiceConfig
    opts = function(_, opts)
      -- Disable cmdline
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.view = "cmdline"

      -- Routes
      opts.routes = vim.list_extend(opts.routes or {}, {
        -- Disable various messages
        {
          opts = { skip = true },
          filter = {
            any = {
              { event = "msg_show", find = "written" },
              { event = "msg_show", find = "%d+ lines, %d+ bytes" },
              { event = "msg_show", find = "%d+L, %d+B" },
              { event = "msg_show", find = "^Hunk %d+ of %d" },
              { event = "msg_show", find = "%d+ change" },
              { event = "msg_show", find = "%d+ line" },
              { event = "msg_show", find = "%d+ more line" },
              { event = "msg_show", find = "%d+ fewer lines" },
            },
          },
        },
      })

      -- Presets
      opts.presets = opts.presets or {}
      opts.presets.lsp_doc_border = core.config.ui.transparent.floats and true or false
    end,
  },
}, {
  catppuccin = {
    noice = true,
  },
  which_key = {
    { "<leader>sn", group = "Noice", mode = { "n", "s" } },
  },
})
