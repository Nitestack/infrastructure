# PowerShell Core library

function Start-Loading
{
  param([string]$message, [string]$colorCode)
  if ([string]::IsNullOrEmpty($colorCode))
  {
    $colorCode = "Yellow"
  }

  Write-Host -NoNewline -ForegroundColor $colorCode "󰇘$message"
}

function Stop-Loading
{
  param([string]$message, [string]$colorCode, [switch]$isSuccess)
  if ([string]::IsNullOrEmpty($colorCode))
  {
    $colorCode = "Green"
  }

  if ($isSuccess)
  {
    $emoji = ""
  }
  else
  {
    $emoji = ""
  }

  $padding = " " * [Console]::WindowWidth
  Write-Host -NoNewline "`r$padding"
  Write-Host -ForegroundColor $colorCode "`r$emoji $message"
}

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
  Write-LogBlue -message " $message"
}
function Write-ManualAction
{
  param([string]$message)
  Write-LogRed -message " $message"
}
function Write-LogError
{
  param([string]$message)
  Write-LogRed -message " $message"
}
function Write-LogInfo
{
  param([string]$message)
  Write-LogBlue -message " $message"
}
function Write-LogSuccess
{
  param([string]$message)
  Write-LogGreen -message " $message"
}
function Write-LogWarning
{
  param([string]$message)
  Write-LogYellow -message " $message"
}

function Write-LogCommand
{
  param([string]$message)
  Write-LogYellow -message " $message"
}
function Invoke-CommandExpression
{
  param([string]$cmd)
  try
  {
    Invoke-Expression $cmd
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
  Start-Loading $cmd_name

  if (Get-Command $cmd_name -ErrorAction SilentlyContinue)
  {
    Stop-Loading $cmd_name
    return
  }

  Invoke-CommandExpression $command
  Stop-Loading $cmd_name
}

function Invoke-ChocoEnsureInstalled
{
  param([string]$package_name)
  Start-Loading $package_name

  if (choco list --lo -r -e $package_name)
  {
    Stop-Loading $package_name
    return
  }

  Invoke-CommandExpression "choco install -y $package_name"
  Stop-Loading $package_name -isSuccess
}

function Invoke-WingetEnsureInstalled
{
  param([string]$package_id)
  $package_name = ($package_id -split "\.")[-1]

  Start-Loading $package_name

  if (winget list --id $package_id)
  {
    Stop-Loading $package_name
    return
  }

  Invoke-CommandExpression "winget install -e --accept-package-agreements --accept-source-agreements --id $package_id"
  Stop-Loading $package_name -isSuccess
}
