param(
  [switch]$PrintSdkPath,
  [switch]$PrintFlutterExecutable,
  [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$toolingDir = Join-Path $repoRoot ".tooling"
$configFile = Join-Path $toolingDir "flutter-sdk-path.txt"
$localSdkRoot = Join-Path $repoRoot ".flutter-sdk"

function Write-SetupInfo {
  param([string]$Message)
  Write-Host "[setup-flutter] $Message"
}

function Get-NormalizedPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $null
  }

  try {
    return [System.IO.Path]::GetFullPath($Path.Trim())
  }
  catch {
    return $null
  }
}

function Get-SdkRootFromFlutterExecutable {
  param([string]$ExecutablePath)

  $fullPath = Get-NormalizedPath $ExecutablePath
  if (-not $fullPath) {
    return $null
  }

  $binDir = Split-Path -Parent $fullPath
  if (-not $binDir) {
    return $null
  }

  if (([System.IO.Path]::GetFileName($binDir)).ToLowerInvariant() -ne "bin") {
    return $null
  }

  return Split-Path -Parent $binDir
}

function Resolve-SdkCandidate {
  param([string]$CandidatePath)

  $normalized = Get-NormalizedPath $CandidatePath
  if (-not $normalized) {
    return $null
  }

  $binDir = Join-Path $normalized "bin"
  $flutterExe = Join-Path $binDir "flutter.bat"
  if (Test-Path -LiteralPath $flutterExe) {
    return [PSCustomObject]@{
      Root = $normalized
      FlutterExe = $flutterExe
    }
  }

  return $null
}

function Save-SdkPath {
  param([string]$SdkRoot)

  New-Item -ItemType Directory -Force -Path $toolingDir | Out-Null

  if (Test-Path -LiteralPath $configFile) {
    $savedPath = (Get-Content -LiteralPath $configFile -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($savedPath -eq $SdkRoot) {
      return
    }
  }

  for ($attempt = 1; $attempt -le 3; $attempt++) {
    try {
      Set-Content -LiteralPath $configFile -Value $SdkRoot -Encoding UTF8
      return
    }
    catch {
      if ($attempt -eq 3) {
        throw
      }
      Start-Sleep -Milliseconds (100 * $attempt)
    }
  }
}

function Resolve-InstalledSdk {
  # 1) explicit env override
  if ($env:CHEFIFY_FLUTTER_SDK) {
    $candidate = Resolve-SdkCandidate $env:CHEFIFY_FLUTTER_SDK
    if ($candidate) {
      return $candidate
    }
  }

  # 2) saved config
  if (Test-Path -LiteralPath $configFile) {
    $savedPath = (Get-Content -Path $configFile -ErrorAction SilentlyContinue | Select-Object -First 1)
    $candidate = Resolve-SdkCandidate $savedPath
    if ($candidate) {
      return $candidate
    }
  }

  # 3) local project SDK
  $candidate = Resolve-SdkCandidate $localSdkRoot
  if ($candidate) {
    return $candidate
  }

  # 4) PATH SDK
  $flutterCommand = Get-Command flutter -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($flutterCommand) {
    $sourcePath = $flutterCommand.Source
    if (-not $sourcePath) {
      $sourcePath = $flutterCommand.Path
    }

    $sdkRoot = Get-SdkRootFromFlutterExecutable $sourcePath
    $candidate = Resolve-SdkCandidate $sdkRoot
    if ($candidate) {
      return $candidate
    }
  }

  return $null
}

function Install-LocalFlutterSdk {
  $existingLocal = Resolve-SdkCandidate $localSdkRoot
  if ($existingLocal) {
    Write-SetupInfo "Local Flutter SDK already exists at '$($existingLocal.Root)'."
    return $existingLocal
  }

  New-Item -ItemType Directory -Force -Path $toolingDir | Out-Null

  $releaseJsonUrl = "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
  Write-SetupInfo "Downloading Flutter release metadata..."
  $releaseIndex = Invoke-RestMethod -Uri $releaseJsonUrl

  $stableHash = $releaseIndex.current_release.stable
  $release = $releaseIndex.releases | Where-Object { $_.hash -eq $stableHash } | Select-Object -First 1
  if (-not $release) {
    throw "Failed to resolve the current stable Flutter release."
  }

  $archiveUrl = "https://storage.googleapis.com/flutter_infra_release/releases/{0}" -f $release.archive
  $archivePath = Join-Path $toolingDir ("flutter_windows_{0}.zip" -f $release.version)

  Write-SetupInfo "Downloading Flutter SDK $($release.version)..."
  if (Test-Path -LiteralPath $archivePath) {
    curl.exe -L -C - -o "$archivePath" "$archiveUrl" | Out-Null
  }
  else {
    curl.exe -L -o "$archivePath" "$archiveUrl" | Out-Null
  }

  if (-not (Test-Path -LiteralPath $archivePath)) {
    throw "Flutter archive was not downloaded."
  }

  Write-SetupInfo "Extracting Flutter SDK..."
  Expand-Archive -LiteralPath $archivePath -DestinationPath $toolingDir -Force

  $extractedRoot = Join-Path $toolingDir "flutter"
  if (-not (Test-Path -LiteralPath $extractedRoot)) {
    throw "Expected extracted folder '$extractedRoot' was not found."
  }

  if (Test-Path -LiteralPath $localSdkRoot) {
    Remove-Item -LiteralPath $localSdkRoot -Recurse -Force
  }

  Move-Item -LiteralPath $extractedRoot -Destination $localSdkRoot

  Write-SetupInfo "Local Flutter SDK installed to '$localSdkRoot'."
  return (Resolve-SdkCandidate $localSdkRoot)
}

$sdk = Resolve-InstalledSdk
if (-not $sdk) {
  if ($NonInteractive) {
    Write-Error "Flutter SDK was not found. Run tools/setup-flutter.ps1 without -NonInteractive to choose manual path or local install."
    exit 1
  }

  Write-SetupInfo "Flutter SDK was not found automatically."
  Write-Host "1) Enter Flutter SDK path manually"
  Write-Host "2) Install local SDK into .flutter-sdk"
  Write-Host "3) Exit"

  $choice = Read-Host "Choose an option (1/2/3)"

  switch ($choice) {
    "1" {
      $manualPath = Read-Host "Enter Flutter SDK root path"
      $sdk = Resolve-SdkCandidate $manualPath
      if (-not $sdk) {
        Write-Error "Flutter SDK was not found at the provided path. Expected: <path>\\bin\\flutter.bat"
        exit 1
      }
    }
    "2" {
      $sdk = Install-LocalFlutterSdk
      if (-not $sdk) {
        Write-Error "Local Flutter SDK install failed."
        exit 1
      }
    }
    default {
      Write-Error "Setup cancelled by user."
      exit 1
    }
  }
}

Save-SdkPath $sdk.Root
Write-SetupInfo "Using Flutter SDK: $($sdk.Root)"

if ($PrintFlutterExecutable) {
  Write-Output $sdk.FlutterExe
}
elseif ($PrintSdkPath) {
  Write-Output $sdk.Root
}
