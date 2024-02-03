<#
.SYNOPSIS
CLI tool for managing dotfiles with chezmoi

.DESCRIPTION
USAGE:
    dotfiles COMMAND
    Get-Help dotfiles
    dotfiles [COMMAND] -h | -Help
    dotfiles -v | -Version

COMMANDS:
    download    Download dotfiles from the internet
    install     Install dotfiles
    update      Update dotfiles and the CLI
    edit        Edit dotfiles

.LINK
https://github.com/Nitestack/dotfiles
#>
param(
  [Parameter(Position=0)]
  [ValidateSet("download", "install", "update", "edit", "-h", "-Help", "-v", "-Version")]
  [string]$Command,

  [Parameter(Position=1, ValueFromRemainingArguments=$true)]
  $Rest,

  [Alias("h")]
  [switch]$Help
)

# PowerShell Core library

function Write-LogColor
{
  param([string]$colorCode, [string]$message)
  Write-Host -Object "$message" -ForegroundColor $colorCode
}
function Write-LogRed
{
  param([string]$message)
  Write-LogColor -colorCode "Red" -message $message
}
function Write-LogBlue
{
  param([string]$message)
  Write-LogColor -colorCode "Blue" -message $message
}
function Write-LogGreen
{
  param([string]$message)
  Write-LogColor -colorCode "Green" -message $message
}
function Write-LogYellow
{
  param([string]$message)
  Write-LogColor -colorCode "Yellow" -message $message
}

function Write-LogTask
{
  param([string]$message)
  Write-LogBlue -message " TASK: $message"
}
function Write-ManualAction
{
  param([string]$message)
  Write-LogRed -message " MANUAL ACTION: $message"
}
function Write-LogError
{
  param([string]$message)
  Write-LogRed -message " ERROR:$message"
}
function Write-LogInfo
{
  param([string]$message)
  Write-LogBlue -message " INFO: $message"
}
function Write-LogSuccess
{
  param([string]$message)
  Write-LogGreen -message " SUCCESS: $message"
}

function Write-LogCommand
{
  param([string]$message)
  Write-LogYellow -message " COMMAND: $message"
}
function Invoke-Command
{
  param([string]$message)
  Write-LogCommand -message $message
  try
  {
    Invoke-Expression $message
  } catch
  {
    Write-LogError -message "Command failed: $_"
  }
}
function Invoke-Error
{
  param([string]$message)
  Write-LogError -message $message
  exit 1
}

function Invoke-Download
{
  <#
.SYNOPSIS
Download dotfiles from a GitHub repository

.DESCRIPTION
USAGE:
    dotfiles download [TARGET] [OPTIONS]
#>
  param(
    [Parameter(Position=0)]
    [Alias("t")]
    [ValidateScript({
        if (Test-Path $_ -IsValid)
        {
          $true
        } else
        {
          throw "Invalid path. Please provide a valid path to a directory."
        }
      })]
    [string]$Target = "$env:USERPROFILE\.dotfiles",

    [Alias("r")]
    [string]$Repo = "Nitestack/dotfiles",

    [Alias("b")]
    [string]$Branch = "master",

    [Switch]$SSH
  )
}


function Invoke-Install
{
  <#
.SYNOPSIS
Install dotfiles with chezmoi

.DESCRIPTION
USAGE:
    dotfiles install [SOURCEDIR] [OPTIONS]
#>
  param(
    [Parameter(Position=0)]
    [Alias("s")]
    [ValidateScript({
        if (Test-Path $_ -IsValid -and (Get-Item $_).PSIsContainer)
        {
          $true
        } else
        {
          throw "Invalid path. Please provide a valid path to an existing directory."
        }
      })]
    [string]$SourceDir = "$env:USERPROFILE\.dotfiles",

    [string]$Bin = "$env:USERPROFILE\.local\bin",
    [Switch]$OneShot
  )
}

function Invoke-Update
{
  <#
.SYNOPSIS
Update dotfiles with chezmoi

.DESCRIPTION
USAGE:
    dotfiles update [OPTIONS]
#>
  param(
    [Alias("R")]
    [ValidateSet("always", "auto", "never")]
    [string]$RefreshExternals = "auto",

    [Alias("l")]
    [Switch]$Local,

    [Switch]$CLI,

    [Alias("n")]
    [Alias("nvim")]
    [Switch]$Neovim
  )
}

function Invoke-Edit
{
  <#
.SYNOPSIS
Edit dotfiles

.DESCRIPTION
USAGE:
    dotfiles edit [TARGET] [OPTIONS]
#>
  param(
    [Parameter(Position=0)]
    [Alias("t")]
    [ValidateScript({
        if (Test-Path $_ -IsValid -and (Get-Item $_).PSIsContainer -eq $false)
        {
          $true
        } else
        {
          throw "Invalid path. Please provide a valid path to an existing file."
        }
      })]
    [string]$Target,

    [Alias("a")]
    [Switch]$Apply,

    [Boolean]$HardLink,

    [Alias("w")]
    [Switch]$Watch
  )
}

# Handling help and version
if ($Command -eq "-h" -or $Command -eq "-Help")
{
  Get-Help $MyInvocation.MyCommand.Definition
  exit
}
if ($Command -eq "-v" -or $Command -eq "-Version")
{
  Write-Host "0.1.0"
  exit
}

# Handling commands
switch ($Command)
{
  "download"
  {
    if ($Help)
    {
      Get-Help Invoke-Download -Full
      exit
    }
    Invoke-Download
  }
  "install"
  {
    if ($Help)
    {
      Get-Help Invoke-Install -Full
      exit
    }
    Invoke-Install
  }
  "update"
  {
    if ($Help)
    {
      Get-Help Invoke-Update -Full
      exit
    }
    Invoke-Update
  }
  "edit"
  {
    if ($Help)
    {
      Get-Help Invoke-Edit -Full
      exit
    }
    Invoke-Edit
  }
  default
  {
    Get-Help $MyInvocation.MyCommand.Definition
  }
}
