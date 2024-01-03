---@type LazyPluginSpec
return {
  "monaqa/dial.nvim",
  keys = core.lazy_map({
    n = {
      ["+"] = {
        function()
          require("dial.map").manipulate("increment", "normal")
        end,
        "Dial: Increment",
      },
      ["-"] = {
        function()
          require("dial.map").manipulate("decrement", "normal")
        end,
        "Dial: Decrement",
      },
      ["g+"] = {
        function()
          require("dial.map").manipulate("increment", "gnormal")
        end,
        "Dial: Increment",
      },
      ["g-"] = {
        function()
          require("dial.map").manipulate("decrement", "gnormal")
        end,
      },
    },
    v = {
      ["+"] = {
        function()
          require("dial.map").manipulate("increment", "visual")
        end,
        "Dial: Increment",
      },
      ["-"] = {
        function()
          require("dial.map").manipulate("decrement", "visual")
        end,
        "Dial: Decrement",
      },
      ["g+"] = {
        function()
          require("dial.map").manipulate("increment", "gvisual")
        end,
        "Dial: Increment",
      },
      ["g-"] = {
        function()
          require("dial.map").manipulate("decrement", "gvisual")
        end,
        "Dial: Decrement",
      },
    },
  }),
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.integer.alias.octal,
        augend.integer.alias.binary,
        augend.constant.alias.de_weekday,
        augend.constant.alias.de_weekday_full,
        augend.constant.alias.bool,
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
      },
    })
  end,
}
