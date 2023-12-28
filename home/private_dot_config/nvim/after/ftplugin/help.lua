core.ft_plugin({
  config = function()
    local opts = { buffer = 0 }

    -- if this a vim help file create mappings to make navigation easier otherwise enable preferred editing settings
    if
      vim.startswith(vim.fn.expand("%") --[[@as string]], vim.env.VIMRUNTIME) or vim.bo.readonly
    then
      -- https://vim.fandom.com/wiki/Learn_to_use_help
      core.map({
        n = {
          ["<CR>"] = {
            "<C-]>",
            "Jump to topic under the cursor",
          },
          ["<BS>"] = {
            "<C-T>",
            "Jump back to where you came from",
          },
        },
      }, opts)
    else
      core.single_map("n", "<leader>ml", {
        "maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a",
        "Set help window width to 80",
        opts = opts,
      })
    end
  end,
})
