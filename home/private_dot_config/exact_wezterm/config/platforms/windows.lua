---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local home_dir = os.getenv("USERPROFILE")
local app_data_local = os.getenv("LOCALAPPDATA")

---@param config Config
function M.setup(config)
  config.integrated_title_button_style = "Windows"

  config.default_prog = { app_data_local .. "\\Microsoft\\WindowsApps\\pwsh.exe", "-NoLogo" }
  config.launch_menu = {
    {
      label = "PowerShell Core",
      args = { app_data_local .. "\\Microsoft\\WindowsApps\\pwsh.exe", "-NoLogo" },
    },
    {
      label = "WSL: Arch",
      args = { home_dir .. "\\Arch\\Arch.exe" },
    },
    {
      label = "WSL: Ubuntu",
      args = { app_data_local .. "\\Microsoft\\WindowsApps\\ubuntu.exe" },
    },
    {
      label = "Command Prompt",
      args = { "cmd" },
    },
    {
      label = "Git Bash",
      args = { app_data_local .. "\\Microsoft\\WindowsApps\\bash.exe" },
    },
  }
  -- Key bindings
  table.insert(config.keys, {
    key = "phys:2",
    mods = "SHIFT|CTRL",
    action = act.SpawnTab({ DomainName = "WSL:Arch" }),
  })
  table.insert(config.keys, {
    key = "phys:3",
    mods = "SHIFT|CTRL",
    action = act.SpawnTab({ DomainName = "WSL:Ubuntu" }),
  })
end

return M
