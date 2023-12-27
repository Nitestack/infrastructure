---@type LazyPluginSpec
return {
  "andweeb/presence.nvim",
  event = "LazyFile",
  opts = {
    neovim_image_text = "Neovim",
    buttons = {
      {
        label = "GitHub",
        url = "https://github.com/Nitestack",
      },
    },
    -- Rich Presence text options
    editing_text = function(file_path)
      return "Editing " .. vim.fn.fnamemodify(file_path, ":t")
    end,
    workspace_text = "Workspace: %s",
  },
}
