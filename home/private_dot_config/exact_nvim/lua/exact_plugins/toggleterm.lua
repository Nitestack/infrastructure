local mapping = "<C-\\>"

---@type LazyPluginSpec
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = core.lazy_map({
    [{ "n", "i", "t" }] = {
      [mapping] = {},
    },
    n = {
      ["<leader>gg"] = {},
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

    opts.open_mapping = mapping
    opts.direction = "float"

    opts.highlights = opts.highlights or {}
    opts.highlights.NormalFloat = {
      link = "NormalFloat",
    }

    opts.float_opts = opts.float_opts or {}
    opts.float_opts.border = core.config.ui.transparent.floats and "curved" or "none"
    opts.width = math.floor(core.config.ui.width * vim.fn.winwidth(0))
    opts.height = math.floor(core.config.ui.height * vim.fn.winheight(0))

    local lazygit = require("toggleterm.terminal").Terminal:new({
      display_name = "LazyGit",
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      hidden = true,
      float_opts = {
        border = core.config.ui.transparent.floats and "curved" or "none",
        width = math.floor(0.9 * vim.fn.winwidth(0)),
        height = math.floor(0.9 * vim.fn.winheight(0)),
      },
      on_open = function(term)
        if not core.falsy(vim.fn.mapcheck("<Esc>", "t")) then
          vim.keymap.del("t", "<Esc>", { buffer = term.bufnr })
        end
      end,
    })

    core.single_map("n", "<leader>gg", {
      function()
        lazygit:toggle()
      end,
      "Git: Lazygit",
      opts = {
        silent = true,
        noremap = true,
      },
    })
  end,
}
