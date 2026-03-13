Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rootDir = Split-Path -Parent $PSScriptRoot
$target = 'i686-pc-windows-msvc'
$cefLibDir = if ($env:CEF_PATH) { $env:CEF_PATH } else { Join-Path $rootDir 'third_party\cef' }
$cefLibPath = Join-Path $cefLibDir 'libcef.lib'
$cefLibUrl = 'https://github.com/ZOTTCE/samp-cef/releases/download/v1.1-beta/libcef.lib'
$dxSdkLib = if ($env:DX_SDK) { $env:DX_SDK } else { Join-Path $rootDir 'third_party\dxsdk\Lib\x86' }
$dxSdkUrl = 'https://download.microsoft.com/download/a/e/7/ae743f1f-632b-4809-87a9-aa1bb3458e31/DXSDK_Jun10.exe'
$sevenZip = 'C:\Program Files\7-Zip\7z.exe'
$nasmFallbacks = @(
    (Join-Path $env:LOCALAPPDATA 'bin\NASM'),
    'C:\Program Files\NASM',
    'C:\Program Files (x86)\NASM'
)

$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

foreach ($nasmDir in $nasmFallbacks) {
    if ((Test-Path (Join-Path $nasmDir 'nasm.exe')) -and ($env:Path -notlike "*$nasmDir*")) {
        $env:Path = "$nasmDir;$env:Path"
    }
}

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    throw 'cargo is required. Install Rust from https://rustup.rs/.'
}

if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
    throw 'rustup is required. Install Rust from https://rustup.rs/.'
}

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    throw 'curl.exe is required to download libcef.lib and the DirectX SDK archive.'
}

if (-not (Get-Command nasm.exe -ErrorAction SilentlyContinue)) {
    throw 'nasm is required for aws-lc-sys. Install it with: winget install -e --id NASM.NASM'
}

if (-not (Test-Path $sevenZip)) {
    throw '7-Zip is required to extract the DirectX SDK archive. Install it with: winget install -e --id 7zip.7zip'
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path $vswhere)) {
    throw 'vswhere.exe not found. Install Visual Studio Build Tools or Visual Studio Community with the Desktop development with C++ workload.'
}

$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) {
    throw 'Visual Studio C++ tools not found. Install the Desktop development with C++ workload.'
}

$launchVsDevShell = Join-Path $vsPath 'Common7\Tools\Launch-VsDevShell.ps1'
if (-not (Test-Path $launchVsDevShell)) {
    throw "Launch-VsDevShell.ps1 not found under $vsPath"
}

if (-not (& rustup target list --installed | Select-String -SimpleMatch $target)) {
    rustup target add $target
}

if (-not (Test-Path $dxSdkLib)) {
    $dxSdkDir = Split-Path -Parent (Split-Path -Parent $dxSdkLib)
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ('samp-cef-dx-' + [guid]::NewGuid())
    $dxExe = Join-Path $tmpDir 'DXSDK_Jun10.exe'

    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dxSdkLib) | Out-Null

    Write-Host "Downloading DirectX SDK (June 2010) to $dxSdkDir"
    & curl.exe -L $dxSdkUrl -o $dxExe
    & $sevenZip x $dxExe 'DXSDK/Lib/x86/*' "-o$($tmpDir)\dx" | Out-Host
    Move-Item (Join-Path $tmpDir 'dx\DXSDK\Lib\x86') $dxSdkLib
    Remove-Item $tmpDir -Recurse -Force
}

if (-not (Test-Path $cefLibPath)) {
    New-Item -ItemType Directory -Force -Path $cefLibDir | Out-Null
    Write-Host "Downloading libcef.lib to $cefLibPath"
    & curl.exe -L $cefLibUrl -o $cefLibPath
}

$env:CEF_PATH = $cefLibDir
$env:LIB = if ($env:LIB) { "$dxSdkLib;$env:LIB" } else { $dxSdkLib }
$env:VSCMD_SKIP_SENDTELEMETRY = '1'

& $launchVsDevShell -Arch x86 -HostArch amd64 | Out-Host
Set-Location $rootDir

Write-Host "Building Windows client artifacts for $target"
& cargo build --release --target $target -p client -p renderer -p loader