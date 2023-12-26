# Copyright (c) 2023 Matheus Castello
# SPDX-License-Identifier: MIT
param(
    [Parameter(Mandatory=$true)]
    [string]$PackageFolder
)

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = "Stop"

# build the deb for all archs
$archs = @(
    "arm64",
    "arm",
    "amd64"
)

$_packName = $PackageFolder.Replace("./", "").Replace("/", "")

# the script was get from here https://github.com/cgzones/container-deb-builder/
foreach ($arch in $archs) {
    Write-Host -ForegroundColor Yellow `
        "Building:"
    Write-Host -ForegroundColor Yellow `
        "`tPackage: $_packName"
    Write-Host -ForegroundColor Yellow `
        "`tPackage arch: $arch"

    # create the ouput folder
    mkdir -p ${_packName}-${arch}

    ./.scripts/build `
        -i commontorizon/deb-builder-${arch}:bookworm-1 `
        -o ${_packName}-${arch} `
        $PackageFolder
}
