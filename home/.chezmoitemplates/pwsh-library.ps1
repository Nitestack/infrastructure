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
function Write-LogWarning
{
  param([string]$message)
  Write-LogYellow -message " WARNING: $message"
}

function Write-LogCommand
{
  param([string]$message)
  Write-LogYellow -message " COMMAND: $message"
}
function Invoke-CommandExpression
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

function Invoke-EnsureInstalled
{
  param([string]$cmd_name, [string]$command)
  if (Get-Command $cmd_name -ErrorAction SilentlyContinue)
  {
    Write-LogInfo "$cmd_name is already installed. Skipping."
    return
  }

  Write-LogTask "Installing $cmd_name"
  Invoke-CommandExpression $command
}

function Invoke-ChocoEnsureInstalled
{
  param([string]$package_name)
  if (choco list --lo -r -e $package_name)
  {
    Write-LogInfo "choco: Package '$package_name' is already installed. Skipping."
    return
  }

  Write-LogTask "choco: Installing package '$package_name'"
  Invoke-CommandExpression "choco install -y $package_name"
}

function Invoke-WingetEnsureInstalled
{
  param([string]$package_name)
  if (winget list --id $package_name)
  {
    Write-LogInfo "winget: Package '$package_name' is already installed. Skipping."
    return
  }

  Write-LogTask "winget: Installing package '$package_name'"
  Invoke-CommandExpression "winget install -e --accept-package-agreements --accept-source-agreements --id $package_name"
}
