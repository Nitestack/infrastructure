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
  Write-LogRed -message " ERROR: $message"
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
function Invoke-EnsureInstalled(
  [string]$command,
  [string]$message
)
{
  if (!(Get-Command $command -ErrorAction SilentlyContinue))
  {
    Write-LogError "Missing dependency: '$command'"
    Invoke-Error "$message"
  }
}
function Invoke-EnsureGitInstalled()
{
  Invoke-EnsureInstalled -command "git" -message "Visit 'https://git-scm.com/downloads' to install git"
}
function Invoke-EnsureChezmoiInstalled()
{
  Invoke-EnsureInstalled -command "chezmoi" -message "Visit 'https://www.chezmoi.io/install' to install chezmoi"
}
function Invoke-EnsureNeovimInstalled()
{
  Invoke-EnsureInstalled -command "nvim" -message "Run 'bob install stable' (or 'bob install nightly' for the nightly release of Neovim) (note that this requires `bob` to be installed)"
}
function Invoke-EnsureBobInstalled()
{
  Invoke-EnsureInstalled -command "bob" -message "Run 'pacman -S bob' if you are on Arch Linux or otherwise 'cargo install bob-nvim' to install bob (note that this requires `cargo` to be installed)"
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
  Write-LogTask "Downloading dotfiles"

  # Set remote depending on the ssh flag
  if ($SSH)
  {
    $Remote = "ssh://github.com/$Repo.git"
  } else
  {
    $Remote = "https://github.com/$Repo.git"
  }

  # Check if dotfiles are already downloaded
  if (Test-Path "$Target")
  {
    $Path = Resolve-Path "$Target"

    Write-LogTask "Cleaning '$Path' with '$Remote' at branch '$Branch'"
    $Git="git -C $Path"
    # Ensure that the remote is set to the correct URL
    if (Invoke-Expression "$Git remote | Select-String `"^origin$`" -Quiet")
    {
      Invoke-Expression "$Git remote set-url origin $Remote"
    } else
    {
      Invoke-Expression "$Git remote add origin $Remote"
    }
    Invoke-Expression "$Git checkout -B $Branch"
    Invoke-Expression "$Git fetch origin $Branch"
    Invoke-Expression "$Git reset --hard FETCH_HEAD"
    Invoke-Expression "$Git clean -fdx"
    Remove-Variable Path, Remote, Branch, Git
  } else
  {
    Write-LogTask "Cloning '$Repo' at branch '$Branch' to '$Target'"
    Invoke-CommandExpression "git clone -b '$Branch' '$Remote' '$Target'"
  }

  Write-LogSuccess "Dotfiles downloaded to '$Target'"
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

    [Switch]$OneShot
  )
  Write-LogTask "Installing dotfiles"

  # Set arguments
  $arguments = @("--source='$SourceDir'", "--verbose=false")

  if ($OneShot)
  {
    $arguments += "--one-shot"
  } else
  {
    $arguments += "--apply"
  }

  Invoke-CommandExpression "chezmoi init $arguments"

  Write-LogSuccess "Installed dotfiles"
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
    [string]$RefreshExternals,

    [Alias("l")]
    [Switch]$Local,

    [Switch]$CLI,

    [Alias("n")]
    [Alias("nvim")]
    [Switch]$Neovim
  )
  Write-LogTask "Updating dotfiles"
  # Check for local/global updates
  $arguments = @()
  if ($Local)
  {
    $arguments += "apply"
  } else
  {
    $arguments += "update"
  }

  if (![string]::IsNullOrEmpty($RefreshExternals))
  {
    $arguments += "--refresh-externals='$RefreshExternals'"
  }

  chezmoi $arguments || Invoke-Error "Failed to update dotfiles"
  Write-LogSuccess "Updated dotfiles"

  # Update the CLI
  if ($CLI)
  {
    $ScriptDir = Resolve-Path "$PSScriptRoot\dotfiles.ps1"
    if (!(Test-Path "$ScriptDir"))
    {
      Invoke-Error "Could not find '$ScriptDir'"
    }
    $UpdatedScriptDir = Resolve-Path "$(chezmoi source-path)\..\scripts\windows\dotfiles.ps1"
    if (!(Test-Path "$UpdatedScriptDir"))
    {
      Invoke-Error "Could not find '$UpdatedScriptDir'"
    }

    # Check if the CLI is already up to date
    if ("$ScriptDir" -eq "$UpdatedScriptDir")
    {
      Write-LogInfo "The CLI is already up to date"
      exit
    }

    Write-LogTask "Updating CLI"
    Copy-Item -Path "$UpdatedScriptDir" -Destination "$ScriptDir" -Force || Invoke-Error "Failed to sync 'dotfiles.ps1' file"
    Write-LogSuccess "Updated CLI to the latest version"
  }

  # Update Neovim related files
  if ($Neovim)
  {
    # Update Neovim
    Write-LogTask "Updating Neovim"
    bob update --all || Invoke-Error "Failed to update Neovim"
    Write-LogSuccess "Updated Neovim to the latest version"

    # Update Lazy plugins and Mason packages
    Write-LogTask "Updating Neovim plugins"
    nvim --headless -c "lua vim.schedule(function() vim.api.nvim_create_autocmd('User', { pattern = 'LazySync', command = 'qa' }); require('lazy').sync({ show = false }) end)" || Invoke-Error "Failed to update Neovim plugins"
    Write-LogSuccess "Updated Neovim plugins"

    Write-LogTask "Updating Mason packages"
    nvim --headless -c "lua vim.schedule(function() vim.api.nvim_create_autocmd('User', { pattern = 'MasonToolsUpdateCompleted', command = 'qa' }); require('mason-tool-installer').check_install(true) end)" || Invoke-Error "Failed to update Mason packages"
    Write-LogSuccess "Updated Mason packages"

    # Sync lazy-lock.json file
    Write-LogTask "Syncing 'lazy-lock.json' file"
    $SourcePath = chezmoi source-path
    $LazyLockPath = (Get-ChildItem -Path $SourcePath -Filter "*lazy-lock.json" -File -Recurse | Select-Object -First 1).FullName
    if ([string]::IsNullOrEmpty($LazyLockPath))
    {
      Write-LogError "Could not find 'lazy-lock.json' file in '$SourcePath'"
    }
    $ConfigPath="$env:LOCALAPPDATA\nvim"
    $UpdatedLazyLockPath = (Get-ChildItem -Path $ConfigPath -Filter "*lazy-lock.json" -File | Select-Object -First 1).FullName
    if ([string]::IsNullOrEmpty($UpdatedLazyLockPath))
    {
      Write-LogError "Could not find 'lazy-lock.json' file in '$ConfigPath'"
    }
    Copy-Item -Path "$UpdatedLazyLockPath" -Destination "$LazyLockPath" -Force || Invoke-Error "Failed to sync 'lazy-lock.json' file"
    Write-LogSuccess "Synced 'lazy-lock.json' file"

    # Commit the updated 'lazy-lock.json' file
    Write-LogTask "Committing 'lazy-lock.json' file"
    # Check if there are any changes
    Invoke-Expression "git diff --quiet -- $LazyLockPath"
    if ($LASTEXITCODE -eq 0)
    {
      Write-LogInfo "No changes in 'lazy-lock.json' file. Skip committing."
      exit
    }
    $CurrentPath = Get-Location
    Set-Location "$(Resolve-Path "$(chezmoi source-path)/..")" || Invoke-Error "Failed to set current path to '$(chezmoi source-path)/..'"
    git add "$LazyLockPath" || Invoke-Error "Failed to add 'lazy-lock.json' file to git"
    git commit "$LazyLockPath" -m "chore(nvim): update lazy-lock.json" || Invoke-Error "Failed to commit 'lazy-lock.json' file"
    Write-LogSuccess "Committed 'lazy-lock.json' file"
    Set-Location "$CurrentPath" || Invoke-Error "Failed to set current path to '$CurrentPath'"
  }
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
        if ((Test-Path $_ -IsValid) -and ((Get-Item $_).PSIsContainer -eq $false))
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

    [Switch]$HardLink,

    [Alias("w")]
    [Switch]$Watch
  )
  if ([string]::IsNullOrEmpty($Target))
  {
    Set-Location $(Resolve-Path "$(chezmoi source-path)/..")
    if (Get-Command nvim -ErrorAction SilentlyContinue)
    {
      nvim
    }
  } else
  {
    $arguments = @($Target)

    if ($Apply)
    {
      $arguments += "--apply"
    }
    if ($HardLink)
    {
      $arguments += "--hardlink=$HardLink"
    }
    if ($Watch)
    {
      $arguments += "--watch"
    }

    Invoke-CommandExpression "chezmoi edit $arguments"
  }
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

# Make sure dependencies are installed
Invoke-EnsureGitInstalled
Invoke-EnsureChezmoiInstalled

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
    Invoke-Expression "Invoke-Download $Rest"
  }
  "install"
  {
    if ($Help)
    {
      Get-Help Invoke-Install -Full
      exit
    }
    Invoke-Expression "Invoke-Install $Rest"
  }
  "update"
  {
    Invoke-EnsureNeovimInstalled
    Invoke-EnsureBobInstalled
    if ($Help)
    {
      Get-Help Invoke-Update -Full
      exit
    }
    Invoke-Expression "Invoke-Update $Rest"
  }
  "edit"
  {
    if ($Help)
    {
      Get-Help Invoke-Edit -Full
      exit
    }
    Invoke-Expression "Invoke-Edit $Rest"
  }
  default
  {
    Get-Help $MyInvocation.MyCommand.Definition
  }
}
