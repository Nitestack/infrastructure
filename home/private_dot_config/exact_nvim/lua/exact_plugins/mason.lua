return utils.plugin.with_extensions({
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, core.config.plugins.mason)
    end,
    -- opts_extend = { "ensure_installed" },
    -- opts = {
    --   ensure_installed = core.config.plugins.mason,
    -- },
    config = function(_, opts)
      opts.ensure_installed = LazyVim.dedup(opts.ensure_installed or {})
      require("mason-tool-installer").setup(opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",
    keys = core.lazy_map({
      n = {
        ["<leader>cm"] = { false },
      },
    }),
    ---@module "mason"
    ---@type MasonSettings
    opts = {
      ui = {
        border = core.config.ui.transparent.floats and "rounded" or "none",
        height = core.config.ui.height,
        width = core.config.ui.width,
        icons = {
          package_pending = core.icons.ui.PackagePending,
          package_installed = core.icons.ui.PackageInstalled,
          package_uninstalled = core.icons.ui.PackageUninstalled,
        },
      },
      pip = {
        upgrade_pip = true,
      },
    },
  },
}, {
  lualine = "mason",
})
