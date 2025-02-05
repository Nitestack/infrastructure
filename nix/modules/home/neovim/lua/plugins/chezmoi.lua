local chezmoi_source_dir = "~/.dotfiles/config"

---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.util.chezmoi" },
  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#source_dir_path"] = chezmoi_source_dir
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
  {
    "xvzc/chezmoi.nvim",
    init = function()
      -- run chezmoi edit on file enter
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { chezmoi_source_dir .. "/*" },
        callback = function()
          vim.schedule(require("chezmoi.commands.__edit").watch)
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ---@param opts utils.plugin.language_config.lsp
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      ---@type (string|{[1]:string, ft:string|string[]})[]
      local modify_servers = {
        "bashls",
        "jsonls",
        "yamlls",
      }

      for _, server_config in ipairs(modify_servers) do
        local server_name
        if type(server_config) == "string" then
          server_name = server_config
        else
          server_name = server_config[1]
        end

        local filetypes = require("lspconfig.configs." .. server_name).default_config.filetypes
        if type(server_config) == "table" then
          vim.list_extend(filetypes, utils.str_to_tbl(server_config.ft))
        end

        opts.servers[server_name] = opts.servers[server_name] or {}
        opts.servers[server_name].filetypes = vim.list_extend(
          filetypes,
          vim.tbl_map(function(filetype)
            return filetype .. ".chezmoitmpl"
          end, filetypes)
        )
      end
    end,
  },
}
