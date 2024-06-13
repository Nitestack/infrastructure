# ╭──────────────────────────────────────────────────────────╮
# │ POWERSHELL LIBRARY                                       │
# ╰──────────────────────────────────────────────────────────╯

function Write-LogError {
  param([String]$Message)
  Write-Host -Object " $Message" -ForegroundColor "Red"
}
function Write-StartTask {
  param([String]$Message)
  Write-Host -Object "󰪥 $Message"
}
function Write-CompleteTask {
  param([String]$Message)
  Write-Host -Object "󰗠 $Message" -ForegroundColor "Green"
}
function Write-LogInfo {
  param([String]$Message)
  Write-Host -Object " $Message"
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
    Write-Host -NoNewline "`r$($SpinnerFrames[$i]) $StartMessage"
    $i = ($i + 1) % $SpinnerFrames.Count
    Start-Sleep -Milliseconds 100
  }

  # Display last spinner frame
  Write-Host -NoNewline "`r$($SpinnerFrames[-1]) $StartMessage"

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
    Write-Host -Object "`r $ControlledExitMessage"
  }
  else {
    Write-Host -ForegroundColor "Green" -Object "`r󰗠 $CompletionMessage"
  }

  $Job | Remove-Job -Force
  Remove-Item -Path $outputFile -Force
}
