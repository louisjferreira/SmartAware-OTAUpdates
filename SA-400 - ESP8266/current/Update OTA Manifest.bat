@echo off
setlocal
set "OTA_DIR=%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $folder=$env:OTA_DIR; $manifestPath=Join-Path $folder 'manifest.json'; if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'manifest.json was not found beside this BAT file.' }; $version=Read-Host 'Enter the firmware version exactly as set in the YAML'; if ([string]::IsNullOrWhiteSpace($version)) { throw 'A firmware version is required.' }; $manifest=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json; if (!$manifest.builds -or $manifest.builds.Count -eq 0) { throw 'The manifest has no builds to update.' }; foreach ($build in $manifest.builds) { $binaryPath=Join-Path $folder $build.ota.path; if (!(Test-Path -LiteralPath $binaryPath -PathType Leaf)) { throw ('OTA binary not found: ' + $binaryPath) }; $build.ota.md5=(Get-FileHash -LiteralPath $binaryPath -Algorithm MD5).Hash.ToLowerInvariant(); Write-Host ('MD5 ' + $build.ota.path + ': ' + $build.ota.md5) }; $manifest.version=$version; $json=$manifest | ConvertTo-Json -Depth 100; [System.IO.File]::WriteAllText($manifestPath,$json,[System.Text.UTF8Encoding]::new($false)); Write-Host ''; Write-Host ('Updated ' + $manifestPath); Write-Host ('Manifest version: ' + $version) } catch { Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"

if errorlevel 1 (
  echo Manifest was not updated.
) else (
  echo Remember to upload manifest.json and the matching OTA binary to GitHub.
)
pause
