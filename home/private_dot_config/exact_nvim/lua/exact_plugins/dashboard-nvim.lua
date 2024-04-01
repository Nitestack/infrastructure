---@type LazyPluginSpec
return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  opts = function(_, opts)
    local logo = string.rep("\n", 8) .. core.config.ui.logo .. "\n\n"
    opts.theme = "doom"
    opts.config = opts.config or {}
    opts.config.header = vim.split(logo, "\n")
    opts.config.center = {
      { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
      { action = "lua require('utils.telescope').builtin('files')", desc = " Find file", icon = " ", key = "f" },
      {
        action = "lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())",
        desc = " Marked Files",
        icon = " ",
        key = "h",
      },
      {
        action = "lua require('utils.telescope').builtin('live_grep')()",
        desc = " Find text",
        icon = " ",
        key = "g",
      },
      { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
      { action = "Mason", desc = " Mason", icon = " ", key = "m" },
      { action = "qa", desc = " Quit", icon = " ", key = "q" },
    }
    opts.config.footer = function()
      local stats = require("lazy").stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
    end

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end
  end,
}
