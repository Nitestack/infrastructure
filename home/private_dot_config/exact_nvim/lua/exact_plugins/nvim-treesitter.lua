---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
      "andymass/vim-matchup",
      "windwp/nvim-ts-autotag",
      "RRethy/nvim-treesitter-endwise",
    },
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    keys = core.lazy_map({
      n = {
        ["<C-Space>"] = {
          desc = "Increment selection",
        },
      },
      x = {
        ["<BS>"] = {
          desc = "Decrement selection",
        },
      },
    }),
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local ensure_installed = vim.list_extend(opts.ensure_installed, core.config.plugins.treesitter)

      ---@type TSConfig
      return {
        ensure_installed = ensure_installed,
        highlight = {
          enable = true,
          -- disable highlighting in chezmoi templates
          disable = function(_lang, buf)
            -- check if 'filetype' option includes 'chezmoitmpl'
            if string.find(vim.bo.filetype, "chezmoitmpl") then
              return true
            end

            -- check for file size
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        -- Auto-install missing parsers on startup
        auto_install = true,
        indent = {
          enable = true,
          -- Disable indent on certain file types
          disable = { "yaml" },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-Space>",
            node_incremental = "<C-Space>",
            scope_incremental = false,
            node_decremental = "<BS>",
          },
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
        },
        -- configure vim-matchup
        matchup = {
          enable = true,
          disable_virtual_text = true,
        },
        -- configure nvim-ts-autotag
        autotag = {
          enable = true,
        },
        -- configure nvim-treesitter-endwise
        endwise = {
          enable = true,
        },
      }
    end,
    config = function(_, opts)
      opts.ensure_installed = utils.remove_duplicates(opts.ensure_installed or {})
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
    event = "LazyFile",
    opts = {
      mode = "cursor",
      max_lines = 3,
      multiline_threshold = 4,
    },
  },
}
