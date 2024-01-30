---@type LazyPluginSpec
return {
  "folke/noice.nvim",
  opts = function(_, opts)
    -- Show @recording messages
    table.insert(opts.routes, {
      view = "notify",
      filter = { event = "msg_showmode" },
    })
    -- Disable various messages
    table.insert(opts.routes, {
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
        },
      },
    })

    -- Disable notify
    -- opts.messages = opts.messages or {}
    -- opts.messages.enabled = true
    -- opts.messages.view = "mini"
    -- opts.messages.view_error = "mini"
    -- opts.messages.view_warn = "mini"
    --
    -- opts.notify = opts.notify or {}
    -- opts.notify.enabled = true
    -- opts.notify.view = "mini"

    -- Disable cmdline
    opts.cmdline = opts.cmdline or {}
    opts.cmdline.view = "cmdline"

    -- Edit lsp options
    opts.lsp = opts.lsp or {}
    opts.lsp.hover = opts.lsp.hover or {}
    opts.lsp.hover.silent = true

    -- opts.lsp.message = opts.lsp.message or {}
    -- opts.lsp.message.view = "mini"

    ---@type NoiceConfigViews
    local views = {
      cmdline_popup = {
        border = core.config.ui.transparent.floats and {
          style = "rounded",
        } or {
          style = "none",
          padding = { 1, 2 },
        },
        win_options = {
          winhighlight = {
            Normal = "NormalFloat",
          },
        },
      },
      mini = {
        position = {
          -- auto-adjust height based on cmdheight (so it doesn't overlap with the statusline)
          row = -1 - vim.o.cmdheight,
        },
      },
    }
    ---@type NoicePresets
    local presets = {
      lsp_doc_border = core.config.ui.transparent.floats and true or false,
    }

    opts.views = vim.tbl_deep_extend("force", opts.views or {}, views)
    opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, presets)
  end,
}
