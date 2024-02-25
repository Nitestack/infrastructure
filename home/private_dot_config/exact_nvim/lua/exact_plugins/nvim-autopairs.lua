---@type LazyPluginSpec
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    fast_wrap = {},
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")

    autopairs.setup(opts)

    -- Move past commas and semicolons
    for _, punct in pairs({ ",", ";" }) do
      autopairs.add_rule(Rule("", punct)
        :with_move(function(o)
          return o.char == punct
        end)
        :with_pair(function()
          return false
        end)
        :with_del(function()
          return false
        end)
        :with_cr(function()
          return false
        end)
        :use_key(punct))
    end

    -- arrow key on javascript
    autopairs.add_rule(Rule("%(.*%)%s*%=>$", " {  }", {
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
    }):use_regex(true):set_end_pair_length(2))
  end,
}
