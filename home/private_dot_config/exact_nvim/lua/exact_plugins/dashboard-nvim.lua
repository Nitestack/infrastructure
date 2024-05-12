---@type LazyPluginSpec
return {
  "nvimdev/dashboard-nvim",
  lazy = false,
  opts = function(_, opts)
    local logo = string.rep("\n", 8) .. core.config.ui.logo .. "\n\n"
    opts.theme = "doom"
    opts.config = opts.config or {}
    opts.config.header = vim.split(logo, "\n")
    opts.config.center = {
      { action = "ene | startinsert", desc = " New file", icon = core.icons.ui.File .. " ", key = "n" },
      { action = "lua utils.telescope('files')", desc = " Find file", icon = core.icons.ui.Search .. " ", key = "f" },
      {
        action = "lua require('grapple').toggle_tags()",
        desc = " Marked Files",
        icon = core.icons.ui.BookMark .. " ",
        key = "h",
      },
      {
        action = "lua utils.telescope('live_grep')()",
        desc = " Find text",
        icon = core.icons.ui.Text .. " ",
        key = "g",
      },
      { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
      { action = "Mason", desc = " Mason", icon = core.icons.ui.Package .. " ", key = "m" },
      { action = "qa", desc = " Quit", icon = core.icons.ui.SignOut .. " ", key = "q" },
    }
    opts.config.footer = function()
      local stats = require("lazy").stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      return { "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
    end

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end
  end,
}
