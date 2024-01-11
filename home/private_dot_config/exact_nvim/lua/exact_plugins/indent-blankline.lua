---@param name string
---@param color string
local function set_cp_hl(name, color)
  vim.api.nvim_set_hl(0, "Rainbow" .. name, { fg = color })
end

---@type LazyPluginSpec
return {
  "lukas-reineke/indent-blankline.nvim",
  dependencies = {
    "HiPhish/rainbow-delimiters.nvim",
  },
  config = function()
    local hooks = require("ibl.hooks")
    local C = require("catppuccin.palettes").get_palette("mocha")

    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      set_cp_hl("Red", C.red)
      set_cp_hl("Yellow", C.yellow)
      set_cp_hl("Blue", C.blue)
      set_cp_hl("Orange", C.peach)
      set_cp_hl("Green", C.green)
      set_cp_hl("Violet", C.mauve)
      set_cp_hl("Cyan", C.teal)
    end)

    require("rainbow-delimiters.setup").setup({
      highlight = highlight,
      query = {
        javascript = "rainbow-delimiters-react",
        tsx = "rainbow-tags-react",
        typescript = "rainbow-parens",
      },
    })
    require("ibl").setup({
      indent = {
        char = core.icons.ui.LineLeft,
        tab_char = core.icons.ui.LineLeft,
      },
      scope = {
        enabled = true,
        char = core.icons.ui.LineLeft,
        highlight = highlight,
      },
    })

    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}
