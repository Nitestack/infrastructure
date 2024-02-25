---@type LazyPluginSpec
return {
  "folke/trouble.nvim",
  cmd = { "TroubleToggle", "Trouble" },
  opts = { use_diagnostic_signs = true },
  keys = core.lazy_map({
    n = {
      ["<leader>xx"] = {
        function()
          require("trouble").toggle({ mode = "document_diagnostics" })
        end,
        "Trouble: Document Diagnostics",
      },
      ["<leader>xX"] = {
        function()
          require("trouble").toggle({ mode = "workspace_diagnostics" })
        end,
        "Trouble: Workspace Diagnostics",
      },
      ["<leader>xL"] = {
        function()
          require("trouble").toggle({ mode = "loclist" })
        end,
        "Trouble: Location List",
      },
      ["<leader>xQ"] = {
        function()
          require("trouble").toggle({ mode = "quickfix" })
        end,
        "Trouble: Quickfix List",
      },
      ["[q"] = {
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        "Previous trouble/quickfix item",
      },
      ["]q"] = {
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        "Next trouble/quickfix item",
      },
    },
  }),
}
