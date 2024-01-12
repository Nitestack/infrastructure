---@type LazySpec
return {
  {
    "echasnovski/mini.indentscope",
    opts = {
      symbol = core.icons.ui.LineLeft,
    },
  },
  {
    "echasnovski/mini.move",
    keys = core.lazy_map({
      [{ "n", "x" }] = {
        [{ "<M-j>", "<M-k>", "<M-h>", "<M-l>" }] = {},
      },
    }),
    opts = {},
  },
  {
    "echasnovski/mini.ai",
    event = function()
      return {
        "LazyFile",
      }
    end,
  },
  {
    "echasnovski/mini.comment",
    event = function()
      return {}
    end,
    keys = core.lazy_map({
      n = {
        ["gcc"] = {},
      },
      [{ "n", "x", "o" }] = {
        ["gc"] = {},
      },
    }),
  },
  {
    "echasnovski/mini.pairs",
    event = function()
      return { "InsertEnter" }
    end,
  },
  {
    import = "lazyvim.plugins.extras.util.mini-hipatterns",
  },
}
