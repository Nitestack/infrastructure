---@type LazyPluginSpec
return {
  "Bekaboo/dropbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  event = "LazyFile",
  ---@type dropbar_configs_t?
  opts = {
    general = {
      update_interval = 500,
    },
    icons = {
      kinds = {
        symbols = vim.tbl_map(function(icon)
          return icon .. " "
        end, core.icons.kind),
      },
      ui = {
        bar = {
          separator = core.icons.ui.ChevronShortRight .. " ",
        },
        menu = {
          indicator = core.icons.ui.ChevronShortRight .. " ",
        },
      },
    },
    bar = {
      sources = function(buf, _)
        local sources = require("dropbar.sources")
        -- local utils = require("dropbar.utils")
        if vim.bo[buf].ft == "markdown" then
          return {
            sources.path,
            sources.markdown,
          }
        end
        if vim.bo[buf].buftype == "terminal" then
          return {
            sources.terminal,
          }
        end
        return {
          sources.path,
          -- utils.source.fallback({
          --   sources.lsp,
          --   sources.treesitter,
          -- }),
        }
      end,
    },
  },
}
