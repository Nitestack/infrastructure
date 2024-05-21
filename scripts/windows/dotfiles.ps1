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
  [Parameter(Position = 0)]
  [ValidateSet("download", "install", "update", "edit", "-h", "-Help", "-v", "-Version")]
  [string]$Command,

  [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
  $Rest,

  [Alias("h")]
  [Switch]$Help
)

# PowerShell Core library

function Write-LogError {
  param([String]$Message)
  Write-Host -Object " $Message" -ForegroundColor "Red"
}
function Write-StartTask {
  param([String]$Message)
  Write-Host -Object "󰪥 $Message" -ForegroundColor "Yellow"
}
function Write-CompleteTask {
  param([String]$Message)
  Write-Host -Object "󰗠 $Message" -ForegroundColor "Green"
}
function Invoke-CommandExpression {
  param([String]$Message)
  try {
    Invoke-Expression $Message
  }
  catch {
    throw "Command failed: $_"
  }
}

function Show-Spinner {
  param (
    [String]$ScriptBlock,
    [String]$StartMessage,
    [String]$CompletionMessage,
    [Switch]$ShowLogs,
    [String]$Prefix = ":"
  )
  [String[]]$SpinnerFrames = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")

  $outputFile = [System.IO.Path]::GetTempFileName()

  $Job = Start-Job -ScriptBlock {
    param([String]$ScriptBlock, [String]$OutputFile)
    try {
      & ([ScriptBlock]::Create($ScriptBlock)) *>&1 | Out-File -FilePath $OutputFile -Append
    }
    catch {
      $_ | Out-String | Out-File -FilePath $OutputFile -Append
      throw
    }
  } -ArgumentList $ScriptBlock, $outputFile

  $i = 0

  while ($Job.State -eq "Running") {
    Write-Host -NoNewline -ForegroundColor "Yellow" "`r$($SpinnerFrames[$i]) $StartMessage"
    $i = ($i + 1) % $SpinnerFrames.Count
    Start-Sleep -Milliseconds 100
  }

  # Display last spinner frame
  Write-Host -NoNewline -ForegroundColor "Yellow" "`r$($SpinnerFrames[-1]) $StartMessage"

  # Read job output from the file
  $JobOutput = Get-Content -Path $outputFile

  # Display logs or errors
  $HasError = $Job.ChildJobs[0].JobStateInfo.State -eq "Failed"
  if ($ShowLogs -or $HasError) {
    Write-Host
    $IsError = $false
    foreach ($line in $JobOutput) {
      if ($line -match "Exception:") {
        $IsError = $true
      }
      if ($IsError) {
        Write-Host -ForegroundColor Red -Object $line
      }
      else {
        Write-Host -Object $line
      }
    }
  }

  # Check for controlled exit
  $HasControlledExit = $false
  $ControlledExitMessage = $null
  foreach ($line in $JobOutput) {
    if ($line -is [string] -and $line.StartsWith($Prefix)) {
      $HasControlledExit = $true
      $ControlledExitMessage = $line.Substring($Prefix.Length).Trim()
      break
    }
  }

  $Padding = " " * [Console]::WindowWidth
  Write-Host -NoNewline "`r$Padding"
  if ($HasError) {
    Write-Host -ForegroundColor Red -Object "`r An unexpected error occurred"
  }
  elseif ($HasControlledExit) {
    Write-Host -ForegroundColor Yellow -Object "`r $ControlledExitMessage"
  }
  else {
    Write-Host -ForegroundColor "Green" -Object "`r󰗠 $CompletionMessage"
  }

  $Job | Remove-Job -Force
  Remove-Item -Path $outputFile -Force
}

function Invoke-EnsureInstalled {
  param([String]$Command, [String]$Message)
  if (!(Get-Command $Command -ErrorAction SilentlyContinue)) {
    Write-LogError -Message "Missing dependency: '$Command'"
    Write-LogError -Message $Message
    exit 1
  }
}
function Invoke-EnsureGitInstalled() {
  Invoke-EnsureInstalled -Command "git" -Message "Visit 'https://git-scm.com/downloads' to install git"
}
function Invoke-EnsureChezmoiInstalled() {
  Invoke-EnsureInstalled -Command "chezmoi" -Message "Visit 'https://www.chezmoi.io/install' to install chezmoi"
}
function Invoke-EnsureNeovimInstalled() {
  Invoke-EnsureInstalled -Command "nvim" -Message "Run 'bob install stable' (or 'bob install nightly' for the nightly release of Neovim) (note that this requires `bob` to be installed)"
}
function Invoke-EnsureBobInstalled() {
  Invoke-EnsureInstalled -Command "bob" -Message "Run 'pacman -S bob' if you are on Arch Linux or otherwise 'cargo install bob-nvim' to install bob (note that this requires `cargo` to be installed)"
}

function Invoke-Download {
  <#
.SYNOPSIS
Download dotfiles from a GitHub repository

.DESCRIPTION
USAGE:
    dotfiles download [TARGET] [OPTIONS]
#>
  param(
    [Parameter(Position = 0)]
    [Alias("t")]
    [ValidateScript({
        if (Test-Path $_ -IsValid) {
          $true
        }
        else {
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

  # Set remote depending on the ssh flag
  if ($SSH) {
    $Remote = "ssh://github.com/$Repo.git"
  }
  else {
    $Remote = "https://github.com/$Repo.git"
  }

  # Check if dotfiles are already downloaded
  if (Test-Path "$Target") {
    Write-StartTask "Cleaning '$Path' with '$Remote' at branch '$Branch'"
    $Path = Resolve-Path "$Target"
    $Git = "git -C $Path"
    # Ensure that the remote is set to the correct URL
    if (Invoke-CommandExpression "$Git remote | Select-String `"^origin$`" -Quiet") {
      Invoke-CommandExpression "$Git remote set-url origin $Remote"
    }
    else {
      Invoke-CommandExpression "$Git remote add origin $Remote"
    }
    Invoke-CommandExpression "$Git checkout -B $Branch"
    Invoke-CommandExpression "$Git fetch origin $Branch"
    Invoke-CommandExpression "$Git reset --hard FETCH_HEAD"
    Invoke-CommandExpression "$Git clean -fdx"
    Remove-Variable Path, Remote, Branch, Git
    Write-CompleteTask "Cleaned existing dotfiles"
  }
  else {
    Write-StartTask "Downloading '$Repo' at '$Branch' to '$Target'"
    Invoke-CommandExpression "git clone -b '$Branch' '$Remote' '$Target'"
    Write-CompleteTask "Downloaded dotfiles"
  }
}

function Invoke-Install {
  <#
.SYNOPSIS
Install dotfiles with chezmoi

.DESCRIPTION
USAGE:
    dotfiles install [SOURCEDIR] [OPTIONS]
#>
  param(
    [Parameter(Position = 0)]
    [Alias("s")]
    [ValidateScript({
        if (Test-Path $_ -IsValid -and (Get-Item $_).PSIsContainer) {
          $true
        }
        else {
          throw "Invalid path. Please provide a valid path to an existing directory."
        }
      })]
    [String]$SourceDir = "$env:USERPROFILE\.dotfiles",

    [Switch]$OneShot
  )

  Write-StartTask "Installing dotfiles"
  # Set arguments
  $arguments = @("--source='$SourceDir'", "--verbose=false")
  if ($OneShot) {
    $arguments += "--one-shot"
  }
  else {
    $arguments += "--apply"
  }
  Invoke-Expression "chezmoi init $arguments" || throw "Failed to install dotfiles"
  Write-CompleteTask "Installed dotfiles"
}

function Invoke-Update {
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

  Write-StartTask "Updating dotfiles"
  # Check for local/global updates
  $arguments = @()
  if ($Local) {
    $arguments += "apply"
  }
  else {
    $arguments += "update"
  }
  if (![string]::IsNullOrEmpty($RefreshExternals)) {
    $arguments += "--refresh-externals='$RefreshExternals'"
  }
  chezmoi $arguments || throw "Failed to update dotfiles"
  Write-CompleteTask "Updated dotfiles"

  # Update the CLI
  if ($CLI) {
    Show-Spinner -StartMessage "Updating CLI" -CompletionMessage "Updated CLI" -ScriptBlock {
      $ScriptDir = Resolve-Path "$env:USERPROFILE\.local\bin\dotfiles.ps1"
      Write-Host "Script dir: $ScriptDir"
      if (!(Test-Path "$ScriptDir")) {
        throw "Could not find '$ScriptDir'"
      }
      $UpdatedScriptDir = Resolve-Path "$(chezmoi source-path)\..\scripts\windows\dotfiles.ps1"
      if (!(Test-Path "$UpdatedScriptDir")) {
        throw "Could not find '$UpdatedScriptDir'"
      }

      # Check if the CLI is already up to date
      if ("$ScriptDir" -eq "$UpdatedScriptDir") {
        return ":The CLI is already up to date"
      }

      Copy-Item -Path "$UpdatedScriptDir" -Destination "$ScriptDir" -Force || throw "Failed to sync 'dotfiles.ps1' file"
    }
  }

  # Update Neovim related files
  if ($Neovim) {
    # Update Neovim
    Show-Spinner -StartMessage "Updating Neovim" -CompletionMessage "Updated Neovim" -ScriptBlock {
      bob update --all || throw "Failed to update Neovim"
    }

    # Update Lazy plugins and Mason packages
    Show-Spinner -StartMessage "Updating Neovim plugins" -CompletionMessage "Updated Neovim plugins" -ScriptBlock {
      nvim --headless -c "Lazy! sync" +qa || throw "Failed to update Neovim plugins"
    }

    Show-Spinner -StartMessage "Updating Mason packages" -CompletionMessage "Updated Mason packages" -ScriptBlock {
      nvim --headless -c "lua vim.schedule(function() vim.api.nvim_create_autocmd('User', { pattern = 'MasonToolsUpdateCompleted', command = 'qa' }); require('mason-tool-installer').check_install(true) end)" || throw "Failed to update Mason packages"
    }

    # Sync lazy-lock.json file
    Show-Spinner -StartMessage "Syncing 'lazy-lock.json' file" -CompletionMessage "Synced 'lazy-lock.json' file" -ScriptBlock {
      $SourcePath = chezmoi source-path
      $LazyLockPath = (Get-ChildItem -Path $SourcePath -Filter "*lazy-lock.json" -File -Recurse | Select-Object -First 1).FullName
      if ([string]::IsNullOrEmpty($LazyLockPath)) {
        throw "Could not find 'lazy-lock.json' file in '$SourcePath'"
      }
      $ConfigPath = "$env:LOCALAPPDATA\nvim"
      $UpdatedLazyLockPath = (Get-ChildItem -Path $ConfigPath -Filter "*lazy-lock.json" -File | Select-Object -First 1).FullName
      if ([string]::IsNullOrEmpty($UpdatedLazyLockPath)) {
        throw "Could not find 'lazy-lock.json' file in '$ConfigPath'"
      }
      Copy-Item -Path "$UpdatedLazyLockPath" -Destination "$LazyLockPath" -Force || throw "Failed to sync 'lazy-lock.json' file"
    }

    # Commit the updated 'lazy-lock.json' file
    Show-Spinner -StartMessage "Committing 'lazy-lock.json' file" -CompletionMessage "Committed 'lazy-lock.json' file" -ScriptBlock {
      $SourcePath = chezmoi source-path
      $LazyLockPath = (Get-ChildItem -Path $SourcePath -Filter "*lazy-lock.json" -File -Recurse | Select-Object -First 1).FullName
      # Check if there are any changes
      Invoke-Expression "git diff --quiet -- $LazyLockPath"
      if ($LASTEXITCODE -eq 0) {
        return ":No changes in 'lazy-lock.json' file"
      }
      $CurrentPath = Get-Location
      Set-Location "$(Resolve-Path "$(chezmoi source-path)/..")" || throw "Failed to set current path to '$(chezmoi source-path)/..'"
      git add "$LazyLockPath" || throw "Failed to add 'lazy-lock.json' file to git"
      git commit "$LazyLockPath" -m "chore(nvim): update lazy-lock.json" || throw "Failed to commit 'lazy-lock.json' file"
      Set-Location "$CurrentPath" || throw "Failed to set current path to '$CurrentPath'"
    }
  }
}

function Invoke-Edit {
  <#
.SYNOPSIS
Edit dotfiles

.DESCRIPTION
USAGE:
    dotfiles edit [TARGET] [OPTIONS]
#>
  param(
    [Parameter(Position = 0)]
    [Alias("t")]
    [ValidateScript({
        if ((Test-Path $_ -IsValid) -and ((Get-Item $_).PSIsContainer -eq $false)) {
          $true
        }
        else {
          throw "Invalid path. Please provide a valid path to an existing file."
        }
      })]
    [string]$Target,

    [Alias("n")]
    [Switch]$Neovide,

    [Alias("a")]
    [Switch]$Apply,

    [Switch]$HardLink,

    [Alias("w")]
    [Switch]$Watch
  )
  if ([string]::IsNullOrEmpty($Target)) {
    Set-Location $(Resolve-Path "$(chezmoi source-path)/..")
    if ($Neovide -and (Get-Command neovide -ErrorAction SilentlyContinue)) {
      neovide
    }
    elseif (Get-Command nvim -ErrorAction SilentlyContinue) {
      nvim
    }
  }
  else {
    $arguments = @($Target)

    if ($Apply) {
      $arguments += "--apply"
    }
    if ($HardLink) {
      $arguments += "--hardlink=$HardLink"
    }
    if ($Watch) {
      $arguments += "--watch"
    }

    Invoke-Expression "chezmoi edit $arguments"
  }
}

# Handling help and version
if ($Command -eq "-h" -or $Command -eq "-Help") {
  Get-Help $MyInvocation.MyCommand.Definition
  exit
}
if ($Command -eq "-v" -or $Command -eq "-Version") {
  Write-Host "0.1.0"
  exit
}

# Make sure dependencies are installed
Invoke-EnsureGitInstalled
Invoke-EnsureChezmoiInstalled

# Handling commands
switch ($Command) {
  "download" {
    if ($Help) {
      Get-Help Invoke-Download -Full
      exit
    }
    Invoke-Expression "Invoke-Download $Rest"
  }
  "install" {
    if ($Help) {
      Get-Help Invoke-Install -Full
      exit
    }
    Invoke-Expression "Invoke-Install $Rest"
  }
  "update" {
    Invoke-EnsureNeovimInstalled
    Invoke-EnsureBobInstalled
    if ($Help) {
      Get-Help Invoke-Update -Full
      exit
    }
    Invoke-Expression "Invoke-Update $Rest"
  }
  "edit" {
    if ($Help) {
      Get-Help Invoke-Edit -Full
      exit
    }
    Invoke-Expression "Invoke-Edit $Rest"
  }
  default {
    Get-Help $MyInvocation.MyCommand.Definition
  }
}
