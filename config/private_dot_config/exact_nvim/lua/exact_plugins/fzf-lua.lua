return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.editor.fzf" },
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      -- Win options
      opts.winopts = opts.winopts or {}
      opts.winopts.preview = opts.winopts.preview or {}
      opts.winopts.preview.layout = "vertical"

      -- Files
      opts.files = opts.files or {}
      opts.files.previewer = false
    end,
  },
}, {
  lualine = "fzf",
  catppuccin = {
    fzf = true,
  },
})
