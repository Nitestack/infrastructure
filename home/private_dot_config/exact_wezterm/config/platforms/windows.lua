local M = {}

---@param config Config
function M.setup(config)
  config.default_prog = { "pwsh", "-NoLogo" }
  config.launch_menu = {
    { label = "PowerShell Core", args = { "pwsh", "-NoLogo" } },
    {
      label = "WSL: Ubuntu",
      args = { "C:\\Users\\hydra\\AppData\\Local\\Microsoft\\WindowsApps\\ubuntu.exe" },
    },
    { label = "Command Prompt", args = { "cmd" } },
    {
      label = "Git Bash",
      args = { "C:\\Users\\hydra\\AppData\\Local\\Microsoft\\WindowsApps\\bash.exe" },
    },
  }
  config.launch_menu = {
    { label = "PowerShell Core", args = { "pwsh", "-NoLogo" } },
    {
      label = "WSL: Ubuntu",
      args = { "C:\\Users\\hydra\\AppData\\Local\\Microsoft\\WindowsApps\\ubuntu.exe" },
    },
    { label = "Command Prompt", args = { "cmd" } },
    {
      label = "Git Bash",
      args = { "C:\\Users\\hydra\\AppData\\Local\\Microsoft\\WindowsApps\\bash.exe" },
    },
  }
  config.window_background_image = "C:\\Users\\hydra\\OneDrive\\Bilder\\PC\\Terminal-Wallpaper_2.png"
  config.window_background_image_hsb = {
    brightness = 0.3,
  }
end

return M
