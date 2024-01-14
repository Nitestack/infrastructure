---@type LazyPluginSpec
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    fast_wrap = {},
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    autopairs.setup(opts)

    local brackets = { { "{", "}" } }
    autopairs.add_rule(
      -- Rule for a pair with left-side ' ' and right side ' '
      Rule(" ", " ")
        -- Pair will only occur if the conditional function returns true
        :with_pair(function(o)
          -- We are checking if we are inserting a space in (), [], or {}
          local pair = o.line:sub(o.col - 1, o.col)
          return vim.tbl_contains({
            brackets[1][1] .. brackets[1][2],
          }, pair)
        end)
        :with_move(cond.none())
        :with_cr(cond.none())
        -- We only want to delete the pair of spaces when the cursor is as such: ( | )
        :with_del(function(o)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local context = o.line:sub(col - 1, col + 2)
          return vim.tbl_contains({
            brackets[1][1] .. "  " .. brackets[1][2],
          }, context)
        end)
    )
    -- For each pair of brackets we will add another rule
    for _, bracket in pairs(brackets) do
      autopairs.add_rule(
        -- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
        Rule(bracket[1] .. " ", " " .. bracket[2])
          :with_pair(cond.none())
          :with_move(function(o)
            return o.char == bracket[2]
          end)
          :with_del(cond.none())
          :use_key(bracket[2])
          -- Removes the trailing whitespace that can occur without this
          :replace_map_cr(function(_)
            return "<C-c>2xi<CR><C-c>O"
          end)
      )
    end

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
