return utils.plugin.with_extensions({
  { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
  {
    "echasnovski/mini.hipatterns",
    opts = {
      tailwind = {
        enabled = false,
      },
    },
  },
  { import = "lazyvim.plugins.extras.editor.mini-files" },
  {
    "echasnovski/mini.files",
    dependencies = "echasnovski/mini.icons",
    keys = core.lazy_map({
      n = {
        ["<leader>e"] = {
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          desc = "Open File Explorer (current dir)",
        },
        ["<leader>E"] = {
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.uv.cwd(), true)
            end
          end,
          desc = "Open File Explorer (cwd)",
        },
        [{ "<leader>fm", "<leader>fM" }] = {
          false,
        },
      },
    }),
  },
  { import = "lazyvim.plugins.extras.editor.mini-move" },
  {
    "echasnovski/mini.move",
    keys = core.lazy_map({
      i = {
        ["<M-j>"] = {
          "<Esc><cmd>m .+1<cr>==gi",
          desc = "Move down",
        },
        ["<M-k>"] = {
          "<Esc><cmd>m .-2<cr>==gi",
          desc = "Move up",
        },
      },
    }),
  },
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
}, {
  catppuccin = {
    mini = {
      enabled = true,
    },
  },
  which_key = {
    { "gs", group = "Surround", mode = { "n", "x" } },
  },
})
