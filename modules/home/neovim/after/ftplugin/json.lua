-- ╭─────────────────────────────────────────────────────────╮
-- │ JSON                                                    │
-- ╰─────────────────────────────────────────────────────────╯

utils.ft_plugin({
  mappings = {
    n = {
      -- Insert comma at end of line, if it doesn't exist
      ["o"] = {
        function()
          local line = vim.api.nvim_get_current_line()
          return line:find("[^,{[]$") and "A,<cr>" or "o"
        end,
        buffer = 0,
        expr = true,
      },
    },
  },
})
