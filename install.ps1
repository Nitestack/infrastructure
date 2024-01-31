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

function Write-LogTask
{
  param([string]$message)
  Write-LogBlue -message "🔃 $message"
}
function Write-LogError
{
  param([string]$message)
  Write-LogRed -message "❌ $message"
}
function Write-ErrorAndExit
{
  param([string]$message)
  Write-LogError -message $message
  exit 1
}

if (!(Get-Command chezmoi -ErrorAction SilentlyContinue))
{
  Write-LogTask "Installing chezmoi"

  winget install twpayne.chezmoi  --accept-package-agreements --accept-source-agreements
}

# Get script's dir
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$scriptDir = (Get-Item -LiteralPath $scriptDir).FullName
$chezmoiArgs = @("init", "--source=$scriptDir", "--verbose=false") + $args

if ($env:DOTFILES_ONE_SHOT)
{
  $chezmoiArgs += "--one-shot"
} else
{
  $chezmoiArgs += "--apply"
}

if ($env:DOTFILES_DEBUG)
{
  $chezmoiArgs += "--debug"
}

Write-LogTask "Running 'chezmoi $chezmoiArgs'"
& chezmoi $chezmoiArgs
