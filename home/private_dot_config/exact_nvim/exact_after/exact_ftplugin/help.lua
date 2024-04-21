--------------------------------------------------------------------------------
--  Vim Help
--------------------------------------------------------------------------------
utils.ft_plugin({
  config = function()
    -- if this a vim help file create mappings to make navigation easier otherwise enable preferred editing settings
    if
      vim.startswith(vim.fn.expand("%") --[[@as string]], vim.env.VIMRUNTIME) or vim.bo.readonly
    then
      -- https://vim.fandom.com/wiki/Learn_to_use_help
      core.map({
        n = {
          ["<CR>"] = {
            "<C-]>",
            desc = "Jump to topic under the cursor",
          },
          ["<BS>"] = {
            "<C-T>",
            desc = "Jump back to where you came from",
          },
        },
      }, { buffer = 0 })
    end
  end,
})
