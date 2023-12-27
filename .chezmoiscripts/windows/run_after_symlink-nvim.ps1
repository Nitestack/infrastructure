if (Test-Path "$env:USERPROFILE\.config\nvim")
{
  Write-Host "Linking $env:LOCALAPPDATA\nvim to $env:USERPROFILE\.config\nvim"
  New-Item -Path "$env:LOCALAPPDATA\nvim" -ItemType SymbolicLink -Value "$env:USERPROFILE\.config\nvim"
}
