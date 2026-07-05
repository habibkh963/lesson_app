
$version = (Select-String -Path "pubspec.yaml" -Pattern "version:\s*(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()


$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"


$debugInfoPath = "debug-info-apk/v$version" + "_$timestamp"


New-Item -ItemType Directory -Force -Path $debugInfoPath | Out-Null


flutter build apk --release --obfuscate --split-debug-info=$debugInfoPath

Write-Host "`n Version was Built successfuly $version"
Write-Host " obfuscation files in: $debugInfoPath"
