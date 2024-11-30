if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match "^([^=]+)=(.*)$") {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}
# Add this after the code block
Write-Host "AZURE_SEARCH_SERVICE = $env:AZURE_SEARCH_SERVICE"
Write-Host "AZURE_SEARCH_INDEX = $env:AZURE_SEARCH_INDEX"

# Only load env from azd if azd command and azd environment exist
if (-not (Get-Command azd -ErrorAction SilentlyContinue)) {
  Write-Host "azd command not found, skipping .env file load"
} else {

  # At the start of prepdocs.ps1


  $output = azd env list
  if (!($output -like "*true*")) {
    Write-Output "No azd environments found, skipping .env file load"
  } else {
    Write-Host "Loading azd .env file from current environment"
    $output = azd env get-values
    foreach ($line in $output) {
      if (!$line.Contains('=')) {
        continue
      }

      $name, $value = $line.Split("=")
      $value = $value -replace '^\"|\"$'
      [Environment]::SetEnvironmentVariable($name, $value)
    }
  }
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
  # fallback to python3 if python not found
  $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

Write-Host 'Creating Python virtual environment ".venv" in root'
Start-Process -FilePath ($pythonCmd).Source -ArgumentList "-m venv ./.venv" -Wait -NoNewWindow

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Write-Host 'Installing dependencies from "requirements.txt" into virtual environment'
Start-Process -FilePath $venvPythonPath -ArgumentList "-m pip install -r ./requirements-dev.txt" -Wait -NoNewWindow
