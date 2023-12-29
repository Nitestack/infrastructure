Write-Host "nvim: Setting up Neovim configuration..."

$symlink_path = "$env:LOCALAPPDATA\nvim"

if (!(Test-Path("$symlink_path")) -or !((Get-Item "$symlink_path").Attributes.ToString() -match "ReparsePoint"))
{
  $target_path = "$env:USERPROFILE\.config\nvim"

  New-Item -Path "$symlink_path" -ItemType SymbolicLink -Value "$target_path"

  Write-Host "      Symbolic link for Neovim configuration created."
  Write-Host "      $symlink_path -> $target_path"
} 
else {
  Write-Host "      Symbolic link for Neovim configuration already exists. Skipping."
}
