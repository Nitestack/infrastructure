---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  event = function()
    return {
      "LazyFile",
    }
  end,
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, core.config.plugins.treesitter)
    end
  end,
  -- ---@param opts TSConfig
  -- config = function(_, opts)
  --   if type(opts.ensure_installed) == "table" then
  --     ---@type table<string, boolean>
  --     local added = {}
  --     opts.ensure_installed = vim.tbl_filter(function(lang)
  --       if added[lang] then
  --         return false
  --       end
  --       added[lang] = true
  --       return true
  --     end, opts.ensure_installed)
  --   end
  --   require("nvim-treesitter.configs").setup(opts)
  --
  --   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  --   parser_config.gotmpl = {
  --     install_info = {
  --       url = "https://github.com/ngalaiko/tree-sitter-go-template",
  --       files = { "src/parser.c" },
  --     },
  --     filetype = "gotmpl",
  --     used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" },
  --   }
  -- end,
}
