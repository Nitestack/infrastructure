-- ╭─────────────────────────────────────────────────────────╮
-- │ Vim                                                     │
-- ╰─────────────────────────────────────────────────────────╯

utils.ft_plugin({
  mappings = {
    n = {
      ["<leader>cs"] = {
        function()
          vim.cmd.source("%")
          vim.notify("Sourced " .. vim.fn.expand("%"))
        end,
        desc = "Source Vimscript file",
      },
    },
  },
})
