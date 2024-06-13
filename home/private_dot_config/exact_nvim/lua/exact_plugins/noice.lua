---@diagnostic disable: assign-type-mismatch
---@type LazyPluginSpec
return {
  "folke/noice.nvim",
  keys = core.lazy_map({
    [{ "n", "s" }] = {
      ["<leader>sn"] = "Noice",
    },
  }),
  ---@module "noice"
  ---@param opts NoiceConfig
  opts = function(_, opts)
    -- Disable cmdline
    opts.cmdline = opts.cmdline or {}
    opts.cmdline.view = "cmdline"

    -- Disable notify
    -- opts.messages = opts.messages or {}
    -- opts.messages.enabled = true
    -- opts.messages.view = "mini"
    -- opts.messages.view_error = "mini"
    -- opts.messages.view_warn = "mini"

    -- LSP
    opts.lsp = opts.lsp or {}
    opts.lsp.message = opts.lsp.message or {}
    opts.lsp.message.view = "mini"
    opts.lsp.hover = opts.lsp.hover or {}
    opts.lsp.hover.silent = true

    -- Routes
    opts.routes = opts.routes or {}
    vim.list_extend(opts.routes, {
      -- Show @recording messages
      {
        view = "notify",
        filter = { event = "msg_showmode" },
      },
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
          },
        },
      },
    })

    -- Views
    opts.views = opts.views or {}
    opts.views.cmdline_popup = {
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
    }
    opts.views.mini = {
      position = {
        -- auto-adjust height based on cmdheight (so it doesn't overlap with the statusline)
        row = -1 - vim.o.cmdheight,
      },
    }

    -- Presets
    opts.presets = opts.presets or {}
    opts.presets.inc_rename = false
    opts.presets.lsp_doc_border = core.config.ui.transparent.floats and true or false
  end,
}
