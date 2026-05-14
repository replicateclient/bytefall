param(
    [string]$Distro = "archlinux",
    [string]$RepoPath = "D:\Bytefall",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

function Test-FirmwareVirtualization {
    $info = systeminfo
    if ($info | Select-String -Pattern "Virtualization Enabled In Firmware:\s+Yes" -Quiet) {
        return $true
    }
    if ($info | Select-String -Pattern "A hypervisor has been detected" -Quiet) {
        return $true
    }
    if ($info | Select-String -Pattern "Virtualization-based security:\s+Status:\s+Running" -Quiet) {
        return $true
    }
    return $false
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "wsl.exe was not found. Install Windows Subsystem for Linux first."
}

if (-not (Test-FirmwareVirtualization)) {
    throw "WSL2 cannot run because virtualization is disabled in BIOS/UEFI. Enable Intel VT-x/AMD-V/SVM, reboot, then re-run this script."
}

$installed = (wsl.exe -l -q) -contains $Distro
if (-not $installed) {
    Write-Host "Installing $Distro for WSL..."
    wsl.exe --install -d $Distro --no-launch
}

$drive = $RepoPath.Substring(0, 1).ToLowerInvariant()
$rest = $RepoPath.Substring(2).Replace("\", "/")
$wslRepo = "/mnt/$drive$rest"
$nativeRepo = "/root/bytefall-src"
$buildFlag = if ($Clean) { "--clean" } else { "--incremental" }

$bootstrap = @"
set -euo pipefail
if [[ ! -d /etc/pacman.d/gnupg/private-keys-v1.d ]]; then
  pacman-key --init
  pacman-key --populate archlinux
fi
pacman -Syu --needed --noconfirm archiso mkinitcpio-archiso git grub rsync squashfs-tools syslinux xorriso mtools dosfstools
mkdir -p '$nativeRepo'
rsync -a --delete --exclude build --exclude out --exclude .git '$wslRepo/' '$nativeRepo/'
cd '$nativeRepo'
chmod +x scripts/*.sh archiso/bytefall/airootfs/root/customize_airootfs.sh archiso/bytefall/airootfs/usr/local/bin/bytefall-installer
chmod +x archiso/bytefall/airootfs/usr/local/bin/bytefall-calamares-root
./scripts/validate-bytefall-tree.sh
./scripts/build-bytefall-iso.sh '$buildFlag'
mkdir -p '$wslRepo/out'
rsync -a --delete --inplace out/ '$wslRepo/out/'
"@

Write-Host "Building Bytefall inside WSL distro $Distro from $wslRepo via native workspace $nativeRepo..."
wsl.exe -d $Distro --user root -- bash -lc $bootstrap
if ($LASTEXITCODE -ne 0) {
    throw "WSL Bytefall build failed with exit code $LASTEXITCODE."
}

$iso = Get-ChildItem -LiteralPath (Join-Path $RepoPath "out") -Filter "bytefall-*.iso" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $iso) {
    throw "WSL build completed but no Bytefall ISO was copied to $RepoPath\out."
}

$minimumSize = 3GB
if ($iso.Length -lt $minimumSize) {
    throw "Bytefall ISO is smaller than 3 GiB: $($iso.Length) bytes."
}

$checksumFile = Join-Path $RepoPath "out\SHA256SUMS"
if (-not (Test-Path -LiteralPath $checksumFile)) {
    throw "WSL build completed but SHA256SUMS was not copied to $RepoPath\out."
}

Write-Host "Bytefall ISO copied to $($iso.FullName) ($($iso.Length) bytes)."
Write-Host "Checksum file copied to $checksumFile."
