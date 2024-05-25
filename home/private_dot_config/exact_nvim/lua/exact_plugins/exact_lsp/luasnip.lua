---@type LazySpec
return {
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  {
    "L3MON4D3/LuaSnip",
    keys = core.lazy_map({
      [{ "i", "s" }] = {
        ["<C-l>"] = {
          function()
            local ls = require("luasnip")
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end,
          desc = "Change choice",
          silent = true,
        },
      },
    }),
    opts = function(_, opts)
      local ls = require("luasnip")
      local extras = require("luasnip.extras")
      local fmt = require("luasnip.extras.fmt")

      opts.history = true
      opts.delete_check_events = "TextChanged"
      opts.enable_autosnippets = true
      opts.update_events = { "TextChanged", "TextChangedI" }
      opts.snip_env = {
        s = ls.snippet,
        ms = ls.multi_snippet,
        sn = ls.snippet_node,
        isn = ls.indent_snippet_node,
        t = ls.text_node,
        i = ls.insert_node,
        f = ls.function_node,
        c = ls.choice_node,
        d = ls.dynamic_node,
        r = ls.restore_node,
        l = extras.lambda,
        rep = extras.rep,
        p = extras.partial,
        m = extras.match,
        n = extras.nonempty,
        dl = extras.dynamic_lambda,
        fmt = fmt.fmt,
        fmta = fmt.fmta,
        conds = require("luasnip.extras.expand_conditions"),
        postfix = require("luasnip.extras.postfix").postfix,
      }
    end,
  },
}
