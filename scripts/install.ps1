param(
  [ValidateScript({
      if (Test-Path $_ -IsValid) {
        $true
      }
      else {
        throw "Invalid path. Please provide a valid path to a directory."
      }
    })]
  [String]$Target = "$env:USERPROFILE\.dotfiles",
  [String]$Branch = "master",
  [Switch]$SSH,
  [Switch]$OneShot
)

# Set remote depending on the ssh flag
if ($SSH) {
  $Remote = "ssh://github.com/Nitestack/dotfiles.git"
}
else {
  $Remote = "https://github.com/Nitestack/dotfiles.git"
}

# Check if dotfiles are already downloaded
if (Test-Path "$Target") {
  $Path = Resolve-Path "$Target"
  $Git = "git -C $Path"
  # Ensure that the remote is set to the correct URL
  if (Invoke-Expression "$Git remote | Select-String `"^origin$`" -Quiet") {
    Invoke-Expression "$Git remote set-url origin $Remote"
  }
  else {
    Invoke-Expression "$Git remote add origin $Remote"
  }
  Invoke-Expression "$Git checkout -B $Branch"
  Invoke-Expression "$Git fetch origin $Branch"
  Invoke-Expression "$Git reset --hard FETCH_HEAD"
  Invoke-Expression "$Git clean -fdx"
}
else {
  git clone -b $Branch $Remote $Target
}

# Set arguments
$Arguments = @("--source='$Target'", "--verbose=false")
if ($OneShot) {
  $Arguments += "--one-shot"
}
else {
  $Arguments += "--apply"
}

chezmoi init $Arguments