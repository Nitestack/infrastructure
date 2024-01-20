---@type LazyPluginSpec
return {
  "akinsho/toggleterm.nvim",
  enabled = not core.config.ui.disable_toggleterm,
  version = "*",
  keys = core.lazy_map({
    [{ "n", "i", "t" }] = {
      ["<C-t>"] = {},
    },
  }),
  ---@param opts ToggleTermConfig
  opts = function(_, opts)
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts.size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end

    opts.open_mapping = "<C-t>"
    opts.direction = "float"

    opts.highlights = opts.highlights or {}
    opts.highlights.NormalFloat = {
      link = "NormalFloat",
    }

    opts.float_opts = opts.float_opts or {}
    opts.float_opts.border = core.config.ui.transparent.floats and "curved" or "none"
    opts.width = math.floor(core.config.ui.width * vim.fn.winwidth(0))
    opts.height = math.floor(core.config.ui.height * vim.fn.winheight(0))
  end,
}
