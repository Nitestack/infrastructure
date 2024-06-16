# ╭──────────────────────────────────────────────────────────╮
# │ POWERSHELL LIBRARY                                       │
# ╰──────────────────────────────────────────────────────────╯

Write-Host

function _Log {
  gum log -s $Args
}

function _Spin {
  param([String]$Title, [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    $Rest)

  gum spin --show-error --spinner points --title $Title $Rest
}

function _Install-PackagesWinget {
  param([string[]]$Packages)

  foreach ($Pkg in $Packages) {
    winget list -e $Pkg | Out-Null
    if ($?) {
      $PackageName = (winget search -e $Pkg | Select-Object -Last 1).Split("$Pkg")[0].Trim()
      _Log -l warn --prefix "winget" "$PackageName is already installed"
      continue
    }

    winget install -e --accept-package-agreements --accept-source-agreements --id $Pkg
  }
}

function _Install-PackagesGallery {
  param([string[]]$Packages)

  foreach ($Pkg in $Packages) {
    if (Get-Module -ListAvailable -Name $Pkg -ErrorAction SilentlyContinue) {
      _Log -l warn --prefix "PowerShell Gallery" "$Pkg is already installed"
      continue
    }

    Install-Module -AcceptLicense -Name $Pkg
  }
}
