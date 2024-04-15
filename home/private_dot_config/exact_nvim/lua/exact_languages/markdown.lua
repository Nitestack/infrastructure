--------------------------------------------------------------------------------
--  Markdown
--------------------------------------------------------------------------------
return utils.plugin.get_language_spec({
  mason = {
    "marksman",
    "markdownlint",
    "prettierd",
    "prettier",
  },
  treesitter = {
    "markdown",
    "markdown_inline",
  },
  lsp = {
    servers = {
      marksman = {},
    },
  },
  formatter = {
    formatters_by_ft = {
      ["markdown"] = { "prettierd", "prettier" },
      ["markdown.mdx"] = { "prettierd", "prettier" },
    },
  },
  linter = {
    linters_by_ft = {
      markdown = { "markdownlint" },
    },
  },
  plugins = {
    {
      "lukas-reineke/headlines.nvim",
      dependencies = "nvim-treesitter/nvim-treesitter",
      ft = { "markdown", "norg", "rmd", "org" },
      opts = function()
        local opts = {}
        for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
          opts[ft] = {
            headline_highlights = {},
            fat_headline_lower_string = "▀",
          }
          for i = 1, 6 do
            local hl = "Headline" .. i
            vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
            table.insert(opts[ft].headline_highlights, hl)
          end
        end
        return opts
      end,
      config = function(_, opts)
        -- PERF: schedule to prevent headlines slowing down opening a file
        vim.schedule(function()
          require("headlines").setup(opts)
          require("headlines").refresh()
        end)
      end,
    },
    {
      "iamcco/markdown-preview.nvim",
      build = "cd app && yarn install",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      keys = core.lazy_map({
        n = {
          ["<leader>cp"] = {
            function()
              vim.cmd("MarkdownPreviewToggle")
            end,
            "Markdown: Toggle preview",
            opts = {
              ft = "markdown",
            },
          },
        },
      }),
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
    },
  },
})
