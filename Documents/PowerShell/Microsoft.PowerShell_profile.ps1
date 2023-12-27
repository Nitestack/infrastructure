$powershell_dev_path = "$env:USERPROFILE\Documents\Programmierung\projects\powershell"

Import-Module Terminal-Icons
Import-Module -Name $powershell_dev_path\Nvim-Switcher

# Aliases
Set-Alias vim nvim.exe
Set-Alias lvim 'C:\Users\hydra\.local\bin\lvim.ps1'

# Utilities
function which($command)
{
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function n()
{ 
  notepad $args 
}

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
  if ($args.Count -gt 0)
  {   
    $argList = "& '" + $args + "'"
    Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
  } else
  {
    Start-Process "$psHome\powershell.exe" -Verb runAs
  }
}
# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights. 
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

# Open PowerShell config with Neovim
function Open-PowerShellConfig()
{
  nvim.exe $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
}
Set-Alias psc Open-PowerShellConfig

Remove-Variable powershell_dev_path

# Open Neovim test environment
function Open-NvimTestEnvironment()
{
  nvim.exe $args --clean
}
Set-Alias nvt Open-NvimTestEnvironment

# Linux utils
function ll()
{ 
  Get-ChildItem -Path $pwd -File 
}
function find-file($name)
{
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Output "${place_path}\${_}"
  }
}
function unzip($file)
{
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}
function ix($file)
{
  curl.exe -F "f:1=@$file" ix.io
}
function grep($regex, $dir)
{
  if ($dir)
  {
    Get-ChildItem $dir | select-string $regex
    return
  }
  $input | select-string $regex
}
function touch($file)
{
  "" | Out-File $file -Encoding ASCII
}
function df
{
  get-volume
}
function sed($file, $find, $replace)
{
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}
function export($name, $value)
{
  set-item -force -path "env:$name" -value $value;
}
function pkill($name)
{
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
function pgrep($name)
{
  Get-Process $name
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\emodipt-extend.omp.json" | Invoke-Expression

