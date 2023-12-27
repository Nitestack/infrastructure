local LazyVimUtil = require("lazyvim.util")

---@param root? boolean
local function neo_tree_toggle(root)
  return {
    function()
      ---@diagnostic disable-next-line: assign-type-mismatch
      local reveal_file = vim.fn.expand("%:p") --[[@type string]]
      if reveal_file == "" then
        ---@diagnostic disable-next-line: cast-local-type
        reveal_file = vim.fn.getcwd()
      else
        local f = io.open(reveal_file, "r")
        if f then
          f.close(f)
        else
          ---@diagnostic disable-next-line: cast-local-type
          reveal_file = vim.fn.getcwd()
        end
      end
      require("neo-tree.command").execute({
        position = "float",
        toggle = true,
        dir = root and LazyVimUtil.root() or vim.loop.cwd(),
        reveal_file = reveal_file and utils.general.resolve_path(reveal_file) or nil,
        reveal_force_cwd = true,
      })
    end,
    "Explorer NeoTree (" .. (root and "root dir" or "cwd") .. ")",
  }
end

---@type LazyPluginSpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "float",
      ---@type NuiPopupOptions
      popup = {
        position = "50%",
        border = {
          style = "none",
          padding = { 1, 1 },
        },
        size = {
          row = "80%",
          col = "80%",
        },
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
      },
    },
    default_component_configs = {
      icon = {
        folder_closed = core.icons.ui.Folder,
        folder_open = core.icons.ui.FolderOpen,
        folder_empty = core.icons.ui.EmptyFolder,
        folder_empty_open = core.icons.ui.EmptyFolderOpen,
      },
    },
  },
  keys = core.lazy_map({
    n = {
      ["<leader>e"] = neo_tree_toggle(true),
      ["<leader>E"] = neo_tree_toggle(false),
      [{ "<leader>fe", "<leader>fE" }] = {
        false,
      },
    },
  }),
}
