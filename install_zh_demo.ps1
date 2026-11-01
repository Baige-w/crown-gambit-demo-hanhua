# Crown Gambit Demo 简体中文汉化补丁
# Self-contained installer: downloads the fan localization v1.2.7 assets from the
# original author's GitHub release, adapts them for the Steam Demo build, and
# rebuilds the game PCK with Simplified Chinese.
# The Chinese translation itself is (c) GreyWolf1101 - https://github.com/GreyWolf1101/Crown-Gambit-Simplified-Chinese
$ErrorActionPreference = 'Stop'

$GameDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$GamePck    = Join-Path $GameDir 'crown_gambit_windows.pck'
$TmpPck     = Join-Path $GameDir 'crown_gambit_windows.zh_installing.tmp'
$Backup     = Join-Path $GameDir 'crown_gambit_windows.before_zh.pck'
$PatchRoot  = "$env:USERPROFILE\Downloads\CrownGambitPatch"
$ZipPath    = Join-Path $PatchRoot 'Crown_Gambit_zh-Hans_v1.2.7_Full.zip'
$PatchDir   = Join-Path $PatchRoot 'v1.2.7_full\patch'
$Tool       = Join-Path $PatchRoot 'v1.2.7_full\tools\gdre_tools.exe'
$ProjectBin = Join-Path $PSScriptRoot 'resources\project.binary'

$ZipUrl        = 'https://github.com/GreyWolf1101/Crown-Gambit-Simplified-Chinese/releases/download/v1.2.7/Crown_Gambit_zh-Hans_v1.2.7_Full.zip'
$ZipSha256Actual = 'c7b78132ea50181054d3811e2d3073aafcdb1503554ffec40df8c08d02e1babf'

$OriginalDemoPckSha256 = 'E9FD9F0DD0F3303DC1FE339C0D779EACBB3250C4907350D3C66C48887637C028'
$PatchedDemoPckSha256  = '9B3DDEDA1444794F8FD22959C2F1504956FC425FE4958E3FCD2C6C43468A4CAF'

if (Get-Process -Name 'crown_gambit_windows' -ErrorAction SilentlyContinue) { throw 'Game is running. Close it first.' }
if (-not (Test-Path -LiteralPath $GamePck)) { throw 'This script must sit in the Crown Gambit Demo game directory (crown_gambit_windows.pck not found next to it).' }
if (-not (Test-Path -LiteralPath $ProjectBin)) { throw 'resources\project.binary is missing. Re-download the full repository.' }

# --- 0. Skip if already patched ---
$CurrentHash = (Get-FileHash -LiteralPath $GamePck -Algorithm SHA256).Hash
if ($CurrentHash -eq $PatchedDemoPckSha256) {
    Write-Host 'Simplified Chinese is already installed. Nothing to do.'
    exit 0
}
if ($CurrentHash -ne $OriginalDemoPckSha256) {
    throw ("Unsupported game files (hash {0}). The patch targets the Steam Demo build 18883383 (game version 1.0.3). `nIf Steam updated or 'verified' the game, check whether a newer patch exists; `nrestore the original via Steam 'Verify integrity of game files' and retry." -f $CurrentHash)
}

$Drive = Get-PSDrive -Name ($GameDir.Substring(0,1))
if ($Drive.Free -lt 16GB) { throw 'Not enough free disk space (need ~16 GB temp during install).' }

# --- 1. Download fan localization v1.2.7 from the original author's release ---
if (-not (Test-Path -LiteralPath $ZipPath)) {
    New-Item -ItemType Directory -Force -Path $PatchRoot | Out-Null
    Write-Host "Downloading fan localization v1.2.7 from the original author's release (~46 MB)..."
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
}
$Got = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash.ToLower()
if ($Got -ne $ZipSha256Actual) { throw "Downloaded zip failed SHA-256 check ($Got). Delete it and retry." }
Write-Host 'Zip SHA-256 OK.'

# --- 2. Extract once ---
if (-not (Test-Path -LiteralPath $Tool)) {
    Write-Host 'Extracting...'
    $tmp = Join-Path $env:TEMP ("cgzh_" + [guid]::NewGuid().ToString('N'))
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $tmp -Force
    $src = Get-ChildItem $tmp -Directory | Select-Object -First 1
    Copy-Item (Join-Path $src.FullName '*') (Join-Path $PatchRoot 'v1.2.7_full') -Recurse -Force
    Remove-Item $tmp -Recurse -Force
}
if (-not (Test-Path -LiteralPath $Tool)) { throw 'gdre_tools.exe not found after extraction.' }

# --- 3. Build localized PCK ---
$Map = [ordered]@{
    "$ProjectBin" = 'res://project.binary'
    "$PatchDir\translations.zh.translation"       = 'res://lang/translations.zh.translation'
    "$PatchDir\master_story.ink.json"             = 'res://story/zh/master_story.ink.json'
    "$PatchDir\master_story.ink.json.import"      = 'res://story/zh/master_story.ink.json.import'
    "$PatchDir\master_story.ink.json-zh-hans.res" = 'res://.godot/imported/master_story.ink.json-zh-hans.res'
    "$PatchDir\settings.scn"           = 'res://.godot/exported/133200997/export-b1b0fb1194681a6a45fa5253fa504900-settings.scn'
    "$PatchDir\encyclopedia.scn"       = 'res://.godot/exported/133200997/export-55c69273e76f27622bd2055dc1429099-encyclopedia.scn'
    "$PatchDir\chapter_end_screen.scn" = 'res://.godot/exported/133200997/export-4c189d52e508d2484a085049a9b5fafc-chapter_end_screen.scn'
    "$PatchDir\level_up.scn"           = 'res://.godot/exported/133200997/export-cffc806b267a45b948e1e99fd5a6de8a-level_up.scn'
    "$PatchDir\game_intro.srt-f29750dd4095393699ee0628fc0d7d1c.res" = 'res://.godot/imported/game_intro.srt-f29750dd4095393699ee0628fc0d7d1c.res'
    "$PatchDir\settings_logic.gdc"   = 'res://scenes/common/settings/settings_logic.gdc'
    "$PatchDir\story_controller.gdc" = 'res://systems/story_controller/story_controller.gdc'
    "$PatchDir\pnj_speechbox.gdc"    = 'res://scenes/dialogue/pnj_speechbox.gdc'
}
foreach ($k in $Map.Keys) {
    if (-not (Test-Path -LiteralPath $k)) { throw "Missing patch file: $k" }
}

$gdreArgs = @('--headless', "--pck-patch=$GamePck", "--output=$TmpPck")
foreach ($k in $Map.Keys) { $gdreArgs += "--patch-file=$k=$($Map[$k])" }

Write-Host 'Building localized PCK (~7.4 GB, usually 10-20 minutes)...'
& $Tool @gdreArgs 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw "gdre_tools failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $TmpPck)) { throw 'Output PCK was not created.' }

# --- 4. Verify, back up original (hardlink), swap ---
$BuiltHash = (Get-FileHash -LiteralPath $TmpPck -Algorithm SHA256).Hash
if ($BuiltHash -ne $PatchedDemoPckSha256) { Remove-Item -LiteralPath $TmpPck -Force; throw ("Built PCK hash mismatch: {0}" -f $BuiltHash) }

if (-not (Test-Path -LiteralPath $Backup)) {
    New-Item -ItemType HardLink -Path $Backup -Target $GamePck -ErrorAction Stop | Out-Null
    Write-Host "Original PCK backed up as: $Backup"
}
Move-Item -LiteralPath $TmpPck -Destination $GamePck -Force
Write-Host 'PCK patched and swapped OK.'

# --- 5. Set language to zh in user settings ---
$SettingsPath = Join-Path $env:APPDATA 'CROWN_GAMBIT\user_settings.tres'
if (Test-Path -LiteralPath $SettingsPath) {
    $Bytes = [IO.File]::ReadAllBytes($SettingsPath)
    $HasBom = $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
    $Off = if ($HasBom) { 3 } else { 0 }
    $Text = [Text.Encoding]::UTF8.GetString($Bytes, $Off, $Bytes.Length - $Off)
    $Text = [regex]::Replace($Text, '(?m)^language = "[a-zA-Z_-]+"(?=\r?$)', 'language = "zh"')
    $Out = [Text.UTF8Encoding]::new($false).GetBytes($Text)
    if ($HasBom) { $Out = [byte[]](@(0xEF,0xBB,0xBF) + $Out) }
    [IO.File]::WriteAllBytes($SettingsPath, $Out)
    Write-Host 'Language set to Simplified Chinese.'
}

Write-Host ''
Write-Host 'DONE! Launch the game from Steam - it should now be in Simplified Chinese.'
Write-Host 'To restore the original: Steam > right-click game > Properties > Installed Files > Verify integrity of game files,'
Write-Host 'then switch the in-game language back to English BEFORE uninstalling/verifying (or delete user_settings.tres).'
