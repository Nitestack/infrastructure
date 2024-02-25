---@type LazyPluginSpec
return {
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
    {
      "windwp/nvim-ts-autotag",
      event = { "BufReadPost", "BufNewFile" },
      opts = {},
    },
    {
      "nvim-treesitter/nvim-treesitter-context",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        mode = "cursor",
        max_lines = 3,
        multiline_threshold = 4,
      },
    },
    "andymass/vim-matchup",
  },
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  -- init = function(plugin)
  --   -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
  --   -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
  --   -- no longer trigger the **nvim-treeitter** module to be loaded in time.
  --   -- Luckily, the only things that those plugins need are the custom queries, which we make available
  --   -- during startup.
  --   require("lazy.core.loader").add_to_rtp(plugin)
  --   require("nvim-treesitter.query_predicates")
  -- end,
  keys = core.lazy_map({
    n = {
      ["<C-Space>"] = {},
    },
    x = {
      ["<BS>"] = {},
    },
  }),
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed --[[@as table]], core.config.plugins.treesitter)
    end

    ---@type TSConfig
    return {
      highlight = {
        enable = true,
        -- disable highlighting in chezmoi templates
        disable = function()
          -- check if 'filetype' option includes 'chezmoitmpl'
          if string.find(vim.bo.filetype, "chezmoitmpl") then
            return true
          end
        end,
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
    }
  end,
}
