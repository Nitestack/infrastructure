---@diagnostic disable: missing-parameter
---@type LazyPluginSpec
return {
  "rmagatti/goto-preview",
  keys = core.lazy_map({
    n = {
      ["gpd"] = {
        function()
          require("goto-preview").goto_preview_definition()
        end,
        "Preview: Goto Definition",
      },
      ["gpt"] = {
        function()
          require("goto-preview").goto_preview_type_definition()
        end,
        "Preview: Goto Type Definition",
      },
      ["gpi"] = {
        function()
          require("goto-preview").goto_preview_implementation()
        end,
        "Preview: Goto Implementation",
      },
      ["gpD"] = {
        function()
          require("goto-preview").goto_preview_declaration()
        end,
        "Preview: Goto Declaration",
      },
      ["gP"] = {
        function()
          require("goto-preview").close_all_win()
        end,
        "Preview: Close Preview",
      },
      ["gpr"] = {
        function()
          require("goto-preview").goto_preview_references()
        end,
        "Preview: Goto References",
      },
    },
  }),
  opts = function(_, opts)
    opts.default_mappings = false
    opts.border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
    opts.post_open_hook = function(bufnr)
      core.single_map("n", "q", {
        vim.cmd.q,
        "Preview: Close Preview",
        opts = {
          noremap = true,
          silent = true,
          buffer = bufnr,
        },
      })
    end
  end,
}
