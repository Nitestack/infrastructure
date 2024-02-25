---@param builtin string
---@param opts? { show_untracked?: boolean }
local function telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts or {}
    if builtin == "files" then
      if vim.loop.fs_stat(vim.loop.cwd() .. "/.git") then
        opts.show_untracked = true
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    require("telescope.builtin")[builtin](opts)
  end
end

---@type LazyPluginSpec
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable("make") == 1,
    },
  },
  keys = core.lazy_map({
    n = {
      [{ "<leader>ff", "<leader><Space>" }] = {
        telescope("files"),
        "Telescope: Find Files",
      },
      [{ "<leader>fw", "<leader>sg" }] = {
        telescope("live_grep"),
        "Telescope: Live Grep",
      },
      ["<leader>fg"] = {
        function()
          require("telescope.builtin").git_files({ show_untracked = true })
        end,
        "Telescope: Git Files",
      },
      ["<leader>sw"] = {
        telescope("grep_string", { word_match = "-w" }),
        "Telescope: Word",
      },
      ["<leader>uC"] = {
        telescope("colorscheme", { enable_preview = true }),
        "Telescope: Colorscheme (with Preview)",
      },
    },
    v = {
      ["<leader>sw"] = {
        telescope("grep_string"),
        "Telescope: Selection",
      },
    },
  }),
  opts = function()
    local actions = require("telescope.actions")
    local trouble_providers = require("trouble.providers.telescope")
    return {
      defaults = {
        prompt_prefix = core.icons.ui.Telescope .. " ",
        selection_caret = core.icons.ui.ChevronShortRight .. " ",
        sorting_strategy = "ascending",
        get_selection_window = function()
          local wins = vim.api.nvim_list_wins()
          table.insert(wins, 1, vim.api.nvim_get_current_win())
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then
              return win
            end
          end
          return 0
        end,
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.5,
          },
          vertical = {
            mirror = false,
          },
          width = core.config.ui.width,
          height = core.config.ui.height,
          preview_cutoff = 120,
        },
        path_display = { "truncate" },
        file_ignore_patterns = { "node_modules" },
        mappings = {
          i = {
            ["<C-t>"] = function(...)
              return trouble_providers.open_with_trouble(...)
            end,
            ["<M-t>"] = function(...)
              return trouble_providers.open_selected_with_trouble(...)
            end,
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          previewer = false,
        },
        git_files = {
          theme = "dropdown",
          previewer = false,
        },
      },
      load_extensions = {
        ["fzf"] = {},
      },
    }
  end,
  config = function(_, opts)
    require("telescope").setup(opts)

    for extension, _ in pairs(opts.load_extensions) do
      require("telescope").load_extension(extension)
    end
  end,
}
