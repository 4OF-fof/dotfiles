[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet("link", "install")]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$dotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$docsDir = Join-Path $dotfilesDir "docs"
$dryRun = $env:DRY_RUN -eq "1"
$doLink = [string]::IsNullOrEmpty($Mode) -or $Mode -eq "link"
$doInstall = [string]::IsNullOrEmpty($Mode) -or $Mode -eq "install"

if (-not (Test-Path -LiteralPath $docsDir -PathType Container)) {
    throw "docs directory not found: $docsDir"
}

$docFiles = @(Get-ChildItem -LiteralPath $docsDir -Filter "*.md" -File | Sort-Object Name)
if ($docFiles.Count -eq 0) {
    throw "no docs files found in: $docsDir"
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

    switch ($HostName.Trim().Trim('"').ToLowerInvariant()) {
        "win" { return "windows" }
        "macos" { return "mac" }
        "darwin" { return "mac" }
        default { return $HostName.Trim().Trim('"').ToLowerInvariant() }
    }
}

function Parse-StringList {
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$RawValue
    )

    if ([string]::IsNullOrWhiteSpace($RawValue)) {
        return @()
    }

    $value = $RawValue.Trim()
    if ($value -match '^\[(.*)\]$') {
        return @([regex]::Matches($matches[1], '"([^"]*)"') | ForEach-Object { $_.Groups[1].Value })
    }

    return @($value.Trim('"'))
}

function Test-HostMatchesWindows {
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$HostSpec
    )

    $hosts = @(Parse-StringList -RawValue $HostSpec | ForEach-Object { Normalize-Host -HostName $_ })
    return $hosts.Count -eq 0 -or $hosts -contains "windows"
}

function Add-UniqueObject {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$List,
        [Parameter(Mandatory = $true)]
        [object]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    if (-not $script:seen.Contains($Key)) {
        $script:seen.Add($Key) | Out-Null
        $List.Add($Value) | Out-Null
    }
}

function Get-FrontMatterDefinitions {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Files
    )

    $links = [System.Collections.ArrayList]::new()
    $scoopApps = [System.Collections.ArrayList]::new()
    $wingetPackages = [System.Collections.ArrayList]::new()
    $script:seen = [System.Collections.Generic.HashSet[string]]::new()
    $foundFrontMatter = $false

    foreach ($file in $Files) {
        $lines = Get-Content -LiteralPath $file.FullName
        if ($lines.Count -eq 0 -or $lines[0] -ne "---") {
            continue
        }

        $foundFrontMatter = $true
        $section = ""
        $currentLink = $null
        $currentScoop = $null
        $inWindows = $false
        $closed = $false

        function Flush-Link {
            if ($null -ne $currentLink -and $currentLink.Source -and $currentLink.Target -and (Test-HostMatchesWindows -HostSpec $currentLink.Host)) {
                $source = if ($currentLink.WindowsSource) { $currentLink.WindowsSource } else { $currentLink.Source }
                $target = if ($currentLink.WindowsTarget) { $currentLink.WindowsTarget } else { $currentLink.Target }
                Add-UniqueObject -List $links -Value ([pscustomobject]@{ Source = $source; Target = $target }) -Key "link`t$source`t$target"
            }
            Set-Variable -Name currentLink -Value $null -Scope 1
        }

        function Flush-Scoop {
            if ($null -ne $currentScoop -and $currentScoop.Source -and $currentScoop.Name) {
                Add-UniqueObject -List $scoopApps -Value ([ordered]@{
                    Info = ""
                    Source = $currentScoop.Source
                    Name = $currentScoop.Name
                }) -Key "scoop`t$($currentScoop.Source)`t$($currentScoop.Name)"
            }
            Set-Variable -Name currentScoop -Value $null -Scope 1
        }

        for ($i = 1; $i -lt $lines.Count; $i++) {
            $rawLine = $lines[$i]
            $line = $rawLine.TrimEnd()

            if ($line -eq "---") {
                Flush-Link
                Flush-Scoop
                $closed = $true
                break
            }

            if ($line -match '^(links|scoop):\s*$') {
                Flush-Link
                Flush-Scoop
                $section = $matches[1]
                $inWindows = $false
                continue
            }

            if ($line -match '^winget:\s*(.+)$') {
                Flush-Link
                Flush-Scoop
                $section = ""
                $packageIdentifier = $matches[1].Trim().Trim('"')
                if ($packageIdentifier) {
                    Add-UniqueObject -List $wingetPackages -Value $packageIdentifier -Key "winget`t$packageIdentifier"
                }
                continue
            }

            if ($line -match '^[A-Za-z0-9_-]+:') {
                Flush-Link
                Flush-Scoop
                $section = ""
                $inWindows = $false
                continue
            }

            if ($section -eq "links" -and $line -match '^  - source:\s*(.+)$') {
                Flush-Link
                $currentLink = [ordered]@{
                    Source = $matches[1].Trim().Trim('"')
                    Target = $null
                    Host = ""
                    WindowsSource = $null
                    WindowsTarget = $null
                }
                $inWindows = $false
                continue
            }

            if ($section -eq "links" -and $null -ne $currentLink -and $line -match '^    windows:\s*$') {
                $inWindows = $true
                continue
            }

            if ($section -eq "links" -and $null -ne $currentLink -and $line -match '^    target:\s*(.+)$' -and -not $inWindows) {
                $currentLink.Target = $matches[1].Trim().Trim('"')
                continue
            }

            if ($section -eq "links" -and $null -ne $currentLink -and $line -match '^    host:\s*(.+)$' -and -not $inWindows) {
                $currentLink.Host = $matches[1].Trim()
                continue
            }

            if ($section -eq "links" -and $null -ne $currentLink -and $line -match '^      source:\s*(.+)$' -and $inWindows) {
                $currentLink.WindowsSource = $matches[1].Trim().Trim('"')
                continue
            }

            if ($section -eq "links" -and $null -ne $currentLink -and $line -match '^      target:\s*(.+)$' -and $inWindows) {
                $currentLink.WindowsTarget = $matches[1].Trim().Trim('"')
                continue
            }

            if ($section -eq "scoop" -and $line -match '^  - source:\s*(.+)$') {
                Flush-Scoop
                $currentScoop = [ordered]@{
                    Source = $matches[1].Trim().Trim('"')
                    Name = $null
                }
                continue
            }

            if ($section -eq "scoop" -and $line -match '^  source:\s*(.+)$') {
                Flush-Scoop
                $currentScoop = [ordered]@{
                    Source = $matches[1].Trim().Trim('"')
                    Name = $null
                }
                continue
            }

            if ($section -eq "scoop" -and $null -ne $currentScoop -and $line -match '^\s+name:\s*(.+)$') {
                $currentScoop.Name = $matches[1].Trim().Trim('"')
                continue
            }
        }

        if (-not $closed) {
            throw "front matter not closed in: $($file.FullName)"
        }
    }

    if (-not $foundFrontMatter) {
        throw "front matter not found in docs: $docsDir"
    }

    return [pscustomobject]@{
        Links = @($links)
        ScoopApps = @($scoopApps)
        WingetPackages = @($wingetPackages)
    }
}

$definitions = Get-FrontMatterDefinitions -Files $docFiles

if ($definitions.Links.Count -eq 0) {
    throw "no link definitions found in docs front matter: $docsDir"
}

if ($doInstall -and $definitions.ScoopApps.Count -gt 0) {
    $scoopFile = [System.IO.Path]::GetTempFileName()
    try {
        $scoopConfig = [ordered]@{
            buckets = @(
                [ordered]@{
                    Name = "main"
                    Source = "https://github.com/ScoopInstaller/Main.git"
                },
                [ordered]@{
                    Name = "extras"
                    Source = "https://github.com/ScoopInstaller/Extras"
                }
            )
            apps = @($definitions.ScoopApps)
        }
        $scoopConfig | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $scoopFile -Encoding UTF8

        if ($dryRun) {
            Write-Host "# Generated Scoopfile"
            Get-Content -LiteralPath $scoopFile | ForEach-Object { Write-Host "DRY_RUN scoopfile: $_" }
        }
        else {
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                throw "Scoop is required to install packages from docs front matter"
            }

            scoop import $scoopFile
        }
    }
    finally {
        Remove-Item -LiteralPath $scoopFile -Force -ErrorAction SilentlyContinue
    }
}

if ($doInstall -and $definitions.WingetPackages.Count -gt 0) {
    $wingetFile = [System.IO.Path]::GetTempFileName()
    try {
        $wingetConfig = [ordered]@{
            '$schema' = "https://aka.ms/winget-packages.schema.2.0.json"
            Sources = @(
                [ordered]@{
                    Packages = @($definitions.WingetPackages | ForEach-Object { [ordered]@{ PackageIdentifier = $_ } })
                    SourceDetails = [ordered]@{
                        Argument = "https://cdn.winget.microsoft.com/cache"
                        Identifier = "Microsoft.Winget.Source_8wekyb3d8bbwe"
                        Name = "winget"
                        Type = "Microsoft.PreIndexed.Package"
                    }
                }
            )
        }
        $wingetConfig | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $wingetFile -Encoding UTF8

        if ($dryRun) {
            Write-Host "# Generated Wingetfile"
            Get-Content -LiteralPath $wingetFile | ForEach-Object { Write-Host "DRY_RUN wingetfile: $_" }
        }
        else {
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                throw "winget is required to install packages from docs front matter"
            }

            winget import -i $wingetFile
        }
    }
    finally {
        Remove-Item -LiteralPath $wingetFile -Force -ErrorAction SilentlyContinue
    }
}

if ($doLink) {
foreach ($linkDefinition in $definitions.Links) {
    $sourcePath = Expand-HomePath -Path $linkDefinition.Source
    $targetPath = Expand-HomePath -Path $linkDefinition.Target

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

    if ($dryRun) {
        Write-Host "DRY_RUN linked: $targetAbs -> $sourceAbs"
        continue
    }

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
}
