Write-Host "nvim: Setting up Neovim configuration..."

$target_path = "$env:LOCALAPPDATA\nvim"
$symlink_path = "$env:USERPROFILE\.config\nvim"

# Check if the path exists
if (!(Test-Path("$symlink_path")))
{
  Write-Host "      Neovim configuration not found. Skipping."
  return
}

# Check if the symbolic link already exists
if (Test-Path("$target_path"))
{
  Write-Host "      Symbolic link for Neovim configuration already exists. Skipping."
  return
}

New-Item -Path "$symlink_path" -ItemType SymbolicLink -Value "$target_path"

Write-Host "      Symbolic link for Neovim configuration created."
Write-Host "      $symlink_path -> $target_path"
