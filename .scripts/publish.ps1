# Copyright (c) 2023 Matheus Castello
# SPDX-License-Identifier: MIT
param(
    [Parameter(Mandatory=$true)]
    [string]$PackageFolder
)

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

$_packName = $PackageFolder.Replace("./", "").Replace("/", "");

# check if the version env is set
if (
    -not $env:DEBIAN_PACKAGES_VERSION
) {
    Write-Host -ForegroundColor Red `
        "DEBIAN_PACKAGES_VERSION env is not set, please set it and try again"
    exit 69
}

$tag = $env:DEBIAN_PACKAGES_VERSION
$_ghDryRun = $null -ne $env:GH_DRY_RUN -and $env:GH_DRY_RUN -eq "true"

# set the repo
# WARNING: this need to be runned in the root of the repo
$env:GH_TOKEN = Get-Content ./.key/gh.key
gh repo set-default commontorizon/debian

if (
    -not $_ghDryRun
) {
    # create the release
    gh release create --prerelease --target main `
        $tag `
        -t "Common Torizon Debian $_packName packages $tag" `
        -n "Common Torizon Debian $_packName packages" `
        ${_packName}-*/*.deb `
} else {
    Write-Host -ForegroundColor Yellow `
        "Skipping GitHub release creation due to GH_DRY_RUN env"
}

Set-Location -
