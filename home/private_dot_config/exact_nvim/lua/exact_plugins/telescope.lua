local telescope_utils = require("utils.telescope")

---@type LazyPluginSpec
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  cmd = "Telescope",
  keys = core.lazy_map({
    n = {
      [{ "<leader>ff", "<leader><Space>" }] = {
        telescope_utils.project_files,
        "Telescope: Find Files",
      },
      [{ "<leader>sg", "<leader>/" }] = {
        telescope_utils.builtin("live_grep"),
        "Telescope: Live Grep",
      },
      ["<leader>sG"] = {
        telescope_utils.builtin("live_grep", {
          additional_args = { "-." },
        }),
        "Telescope: Live Grep (all)",
      },
      ["<leader>fg"] = {
        telescope_utils.builtin("git_files", { show_untracked = true }),
        "Telescope: Git Files",
      },
      ["<leader>sw"] = {
        telescope_utils.builtin("grep_string", { word_match = "-w" }),
        "Telescope: Word",
      },
      ["<leader>sW"] = {
        telescope_utils.builtin("grep_string", {
          word_match = "-w",
          additional_args = { "-." },
        }),
        "Telescope: Word (all)",
      },
    },
    v = {
      ["<leader>sw"] = {
        telescope_utils.builtin("grep_string", { word_match = "-w" }),
        "Telescope: Word Selection",
      },
      ["<leader>sW"] = {
        telescope_utils.builtin("grep_string", {
          word_match = "-w",
          additional_args = { "-." },
        }),
        "Telescope: Word Selection (all)",
      },
    },
  }),
  opts = function()
    local actions = require("telescope.actions")
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
        file_ignore_patterns = { "node_modules", ".git", ".next", "dist", "build", "target" },
        mappings = {
          i = {
            ["<ESC>"] = actions.close,
            ["<C-t>"] = require("trouble.sources.telescope").open,
            ["<C-f>"] = actions.preview_scrolling_down,
            ["<C-b>"] = actions.preview_scrolling_up,
          },
          n = {
            ["q"] = actions.close,
            ["<C-t"] = require("trouble.sources.telescope").open,
          },
        },
        -- Include hidden files, excluding .git
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
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
      pcall(require("telescope").load_extension, extension)
    end
  end,
}
