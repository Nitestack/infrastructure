---@type LazyPluginSpec
return {
  "folke/noice.nvim",
  opts = function(_, opts)
    table.insert(opts.routes, {
      filter = {
        event = "notify",
        find = "No information available",
      },
      opts = { skip = true },
    })

    -- Disable messages view
    opts.messages = opts.messages or {}
    opts.messages.enabled = false

    ---@type NoiceConfigViews
    local views = {
      mini = {
        position = {
          -- Adjust the mini view to work with a bigger cmdline height
          row = -1 - vim.o.cmdheight,
        },
      },
    }
    ---@type NoicePresets
    local presets = {
      lsp_doc_border = false,
    }

    opts.views = vim.tbl_deep_extend("force", opts.views or {}, views)
    opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, presets)
  end,
}
