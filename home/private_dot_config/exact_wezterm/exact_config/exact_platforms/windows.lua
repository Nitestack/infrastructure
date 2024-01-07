return {
  default_prog = { "pwsh", "-NoLogo" },
  launch_menu = {
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
  },
  -- Background
  background = {
    {
      source = {
        File = "C:\\Users\\hydra\\OneDrive\\Bilder\\PC\\Terminal-Wallpaper_1.png",
      },
    },
    {
      source = { Color = "#1E1E2E" },
      height = "100%",
      width = "100%",
      opacity = 0.9,
    },
  },
}
