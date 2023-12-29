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
function Write-LogManualAction
{
  param([string]$message)
  Write-LogRed -message "⚠️ $message"
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

function Invoke-GitClean
{
  param([string]$Path, [string]$Remote, [string]$Branch)
  $Path = (Get-Item -LiteralPath $Path).FullName

  Write-LogTask "Cleaning '$Path' with '$Remote' at branch '$Branch'"
  $Git = "git -C $Path"
  # Ensure that the remote is set to the correct URL
  $remoteExists = Invoke-Expression "$Git remote | Where-Object { `$_ -eq 'origin' }"
  if (!$remoteExists)
  {
    Invoke-Expression "$Git remote add origin $Remote"
  } else
  {
    Invoke-Expression "$Git remote set-url origin $Remote"
  }

  Invoke-Expression "$Git checkout -B $Branch"
  Invoke-Expression "$Git fetch origin $Branch"
  Invoke-Expression "$Git reset --hard FETCH_HEAD"
  Invoke-Expression "$Git clean -fdx"

  Remove-Variable Path, Remote, Branch, Git
}

$env:DOTFILES_REPO_HOST ??= "https://github.com"
$env:DOTFILES_USER ??= "Nitestack"
$env:DOTFILES_REPO = "$env:DOTFILES_REPO_HOST/$env:DOTFILES_USER/dotfiles"
$env:DOTFILES_BRANCH ??= "master"
$env:DOTFILES_DIR = "$env:USERPROFILE\.dotfiles"

if (!(Get-Command "git" -ErrorAction SilentlyContinue))
{
  Write-LogTask "Installing git"
  winget install -e --id Git.Git --source winget --accept-package-agreements --accept-source-agreements
}

if (Test-Path "$env:DOTFILES_DIR" -PathType Container)
{
  Invoke-GitClean -Path $env:DOTFILES_DIR -Remote $env:DOTFILES_REPO -Branch $env:DOTFILES_BRANCH
} else
{
  Write-LogTask "Cloning '$env:DOTFILES_REPO' at branch '$env:DOTFILES_BRANCH' to '$env:DOTFILES_DIR'"
  git clone --branch "$env:DOTFILES_BRANCH" "$env:DOTFILES_REPO" "$env:DOTFILES_DIR"
}

if (Test-Path "$env:DOTFILES_DIR\install.ps1")
{
  $InstallScript = "$env:DOTFILES_DIR\install.ps1"
} else
{
  Write-ErrorAndExit "No install script found in the dotfiles."
}

Write-LogTask "Running '$InstallScript'"
& $InstallScript $args
