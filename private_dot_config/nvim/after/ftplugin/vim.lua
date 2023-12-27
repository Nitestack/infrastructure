core.ft_plugin({
  mappings = {
    n = {
      ["<leader>cs"] = {
        function()
          vim.cmd.source("%")
          vim.notify("Sourced " .. vim.fn.expand("%"))
        end,
        "Source Vimscript file",
      },
    },
  },
})
