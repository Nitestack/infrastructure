if (Test-Path "$env:USERPROFILE\.config\nvim")
{
  New-Item -Path "$env:USERPROFILE\.config\nvim" -ItemType SymbolicLink -Value "$env:LOCALAPPDATA\nvim"
}
