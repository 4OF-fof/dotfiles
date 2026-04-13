[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$dotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installConfig = Join-Path $dotfilesDir "install.toml"

if (-not (Test-Path -LiteralPath $installConfig)) {
    throw "install config not found: $installConfig"
}

function Expand-HomePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Path.StartsWith("~/") -or $Path.StartsWith("~\")) {
        return Join-Path $HOME $Path.Substring(2)
    }

    if ($Path -eq "~") {
        return $HOME
    }

    return $Path
}

function Normalize-Host {
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$HostName
    )

    if ([string]::IsNullOrWhiteSpace($HostName)) {
        return ""
    }

    switch ($HostName.Trim().ToLowerInvariant()) {
        "win" { return "windows" }
        "macos" { return "mac" }
        "darwin" { return "mac" }
        default { return $HostName.Trim().ToLowerInvariant() }
    }
}

function Parse-TomlStringList {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RawValue
    )

    $value = $RawValue.Trim()

    if ($value -match '^"(.*)"$') {
        return @($matches[1])
    }

    if ($value -match '^\[(.*)\]$') {
        $inner = $matches[1].Trim()
        if (-not $inner) {
            return @()
        }

        $items = [System.Collections.Generic.List[string]]::new()
        foreach ($match in [regex]::Matches($inner, '"([^"]*)"')) {
            $items.Add($match.Groups[1].Value)
        }

        if ($items.Count -eq 0) {
            throw "invalid host list: $RawValue"
        }

        return $items.ToArray()
    }

    throw "unsupported TOML string list: $RawValue"
}

function Get-LinkDefinitions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    $definitions = New-Object System.Collections.Generic.List[object]
    $current = $null
    $inWindowsSection = $false

    foreach ($rawLine in Get-Content -LiteralPath $ConfigPath) {
        $line = $rawLine.Trim()

        if (-not $line -or $line.StartsWith("#")) {
            continue
        }

        if ($line -eq "[[link]]") {
            if ($null -ne $current) {
                $definitions.Add([pscustomobject]$current)
            }

            $current = [ordered]@{
                Source        = $null
                Target        = $null
                Hosts         = @()
                WindowsSource = $null
                WindowsTarget = $null
            }
            $inWindowsSection = $false
            continue
        }

        if ($line -eq "[link.windows]") {
            if ($null -eq $current) {
                throw "encountered [link.windows] before [[link]] in: $ConfigPath"
            }

            $inWindowsSection = $true
            continue
        }

        if ($line -match '^\[.+\]$') {
            $inWindowsSection = $false
            continue
        }

        if ($null -eq $current) {
            continue
        }

        if ($line -match '^(source|target)\s*=\s*"(.*)"$') {
            $key = $matches[1]
            $value = $matches[2]

            if ($inWindowsSection) {
                switch ($key) {
                    "source" { $current.WindowsSource = $value }
                    "target" { $current.WindowsTarget = $value }
                }
            }
            else {
                switch ($key) {
                    "source" { $current.Source = $value }
                    "target" { $current.Target = $value }
                }
            }
        }
        elseif (-not $inWindowsSection -and $line -match '^host\s*=\s*(.+)$') {
            $current.Hosts = @(Parse-TomlStringList -RawValue $matches[1])
        }
    }

    if ($null -ne $current) {
        $definitions.Add([pscustomobject]$current)
    }

    return $definitions
}

$linkDefinitions = Get-LinkDefinitions -ConfigPath $installConfig

if ($linkDefinitions.Count -eq 0) {
    throw "no link definitions found in: $installConfig"
}

foreach ($linkDefinition in $linkDefinitions) {
    if ($linkDefinition.Hosts.Count -gt 0) {
        $normalizedHosts = @($linkDefinition.Hosts | ForEach-Object { Normalize-Host -HostName $_ })
        if ($normalizedHosts -notcontains "windows") {
            continue
        }
    }

    $sourcePath = if ($linkDefinition.WindowsSource) { $linkDefinition.WindowsSource } else { $linkDefinition.Source }
    $targetPath = if ($linkDefinition.WindowsTarget) { $linkDefinition.WindowsTarget } else { $linkDefinition.Target }

    if (-not $sourcePath -or -not $targetPath) {
        throw "link definition is missing source or target in: $installConfig"
    }

    $sourcePath = Expand-HomePath -Path $sourcePath
    $targetPath = Expand-HomePath -Path $targetPath

    if ([System.IO.Path]::IsPathRooted($sourcePath)) {
        $sourceAbs = [System.IO.Path]::GetFullPath($sourcePath)
    }
    else {
        $sourceAbs = [System.IO.Path]::GetFullPath((Join-Path $dotfilesDir $sourcePath))
    }

    if (-not (Test-Path -LiteralPath $sourceAbs)) {
        throw "source config not found: $sourceAbs"
    }

    $targetAbs = [System.IO.Path]::GetFullPath($targetPath)
    $targetParent = Split-Path -Parent $targetAbs

    if ($targetParent -and -not (Test-Path -LiteralPath $targetParent)) {
        if ($PSCmdlet.ShouldProcess($targetParent, "Create parent directory")) {
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }
    }

    $existingItem = Get-Item -LiteralPath $targetAbs -Force -ErrorAction SilentlyContinue
    if ($null -ne $existingItem) {
        if ($PSCmdlet.ShouldProcess($targetAbs, "Remove existing item")) {
            Remove-Item -LiteralPath $targetAbs -Recurse -Force
        }
    }

    if ($PSCmdlet.ShouldProcess($targetAbs, "Create symbolic link to $sourceAbs")) {
        New-Item -ItemType SymbolicLink -Path $targetAbs -Target $sourceAbs | Out-Null
        Write-Host "linked: $targetAbs -> $sourceAbs"
    }
}
