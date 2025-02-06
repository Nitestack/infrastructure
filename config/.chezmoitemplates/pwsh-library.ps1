# ╭──────────────────────────────────────────────────────────╮
# │ PowerShell Library                                       │
# ╰──────────────────────────────────────────────────────────╯

Write-Host

function _Log {
  gum log -s $Args
}

function _LogHeader {
  param([string]$Title)
  Write-Output "# $Title" | gum format
}

function _Install-PackagesWinget {
  param([string[]]$Packages)

  foreach ($Pkg in $Packages) {
    winget list -e $Pkg | Out-Null
    if ($?) {
      _Log -l warn --prefix "winget" "$Pkg is already installed"
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
