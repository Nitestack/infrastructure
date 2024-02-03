---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    dependencies = {
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
      },
    },
    keys = core.lazy_map({
      n = {
        ["<leader>cm"] = { false },
      },
    }),
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, core.config.plugins.mason)

      opts.ui = opts.ui or {}
      opts.ui.border = core.config.ui.transparent.floats and "rounded" or "none"
      opts.ui.height = core.config.ui.height
      opts.ui.width = core.config.ui.width
      opts.ui.icons = opts.ui.icons or {}
      opts.ui.icons.package_pending = core.icons.ui.PackagePending
      opts.ui.icons.package_installed = core.icons.ui.PackageInstalled
      opts.ui.icons.package_uninstalled = core.icons.ui.PackageUninstalled

      opts.pip = opts.pip or {}
      opts.pip.upgrade_pip = true
    end,
  },
}
