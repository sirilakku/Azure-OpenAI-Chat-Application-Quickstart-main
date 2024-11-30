. ./scripts/loadenv.ps1

$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./.venv/bin/python"
}

Write-Host 'Running "prepdocs.py"'
$cwd = (Get-Location)
Start-Process -FilePath $venvPythonPath -ArgumentList "./scripts/prepdocs.py --searchservice $env:AZURE_SEARCH_SERVICE --index $env:AZURE_SEARCH_INDEX --searchkey $env:AZURE_SEARCH_KEY --formrecognizerservice $env:AZURE_FORMRECOGNIZER_SERVICE --formrecognizerkey $env:AZURE_FORMRECOGNIZER_KEY --embeddingendpoint $env:AZURE_OPENAI_EMBEDDING_ENDPOINT" -Wait -NoNewWindow
