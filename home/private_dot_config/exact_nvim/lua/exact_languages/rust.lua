return core.load_language({
  treesitter = {
    "rust",
    "ron",
  },
  lsp = {
    servers = {
      rust_analyzer = {},
      taplo = {
        keys = {
          {
            "K",
            function()
              if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                require("crates").show_popup()
              else
                vim.lsp.buf.hover()
              end
            end,
            "Show Crate Documentation",
          },
        },
      },
    },
    setup = {
      rust_analyzer = function()
        return true
      end,
    },
  },
  mason = {
    "codelldb",
    "rust-analyzer",
    "taplo",
  },
  plugins = {
    {
      "Saecki/crates.nvim",
      event = "BufRead Cargo.toml",
      opts = {
        src = {
          cmp = { enabled = true },
        },
      },
    },
    {
      "mrcjkb/rustaceanvim",
      version = "^4", -- Recommended
      ft = { "rust" },
      opts = {
        server = {
          on_attach = function(_, bufnr)
            core.map({
              n = {
                ["<leader>cR"] = {
                  function()
                    vim.cmd.RustLsp("codeAction")
                  end,
                  "Code Action",
                  opts = { buffer = bufnr },
                },
                ["<leader>dr"] = {
                  function()
                    vim.cmd.RustLsp("debuggables")
                  end,
                  "Rust debuggables",
                  opts = { buffer = bufnr },
                },
              },
            })
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
      },
      config = function(_, opts)
        vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      end,
    },
  },
})
