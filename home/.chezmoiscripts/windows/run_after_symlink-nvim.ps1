if (!(Test-Path("$env:LOCALAPPDATA\nvim")) -or !((Get-Item "$env:LOCALAPPDATA\nvim").Attributes.ToString() -match "ReparsePoint"))
{
  Write-Host "Linking $env:LOCALAPPDATA\nvim to $env:USERPROFILE\.config\nvim"
  New-Item -Path "$env:LOCALAPPDATA\nvim" -ItemType SymbolicLink -Value "$env:USERPROFILE\.config\nvim"
}
