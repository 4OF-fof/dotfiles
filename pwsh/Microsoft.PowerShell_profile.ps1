# Module
$moduleRoot = Join-Path $PSScriptRoot "module"
$script:pwshModulePaths = @{}
$script:pwshModuleLoading = @{}
$script:pwshModuleLoaded = @{}
$script:pwshModuleLoadOrder = [System.Collections.Generic.List[string]]::new()

Get-ChildItem -LiteralPath $moduleRoot -Filter *.ps1 -ErrorAction SilentlyContinue |
    Sort-Object -Property Name |
    ForEach-Object {
        $script:pwshModulePaths[[System.IO.Path]::GetFileNameWithoutExtension($_.Name)] = $_.FullName
    }

function Get-PwshModuleDependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $dependencyLine = Get-Content -LiteralPath $Path -TotalCount 20 |
        Where-Object { $_ -match '^\s*#\s*deps\s*:' } |
        Select-Object -First 1

    if (-not $dependencyLine) {
        return @()
    }

    $dependencies = $dependencyLine -replace '^\s*#\s*deps\s*:\s*', ''
    if ([string]::IsNullOrWhiteSpace($dependencies)) {
        return @()
    }

    return @($dependencies -split '\s+' | Where-Object { $_ })
}

function Resolve-PwshModuleLoadOrder {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not $script:pwshModulePaths.ContainsKey($Name)) {
        throw "PowerShell module dependency not found: $Name"
    }

    $path = $script:pwshModulePaths[$Name]

    if ($script:pwshModuleLoaded.ContainsKey($path)) {
        return
    }

    if ($script:pwshModuleLoading.ContainsKey($path)) {
        throw "Circular PowerShell module dependency detected: $Name"
    }

    $script:pwshModuleLoading[$path] = $true

    foreach ($dependency in (Get-PwshModuleDependencies -Path $path)) {
        Resolve-PwshModuleLoadOrder -Name $dependency
    }

    $null = $script:pwshModuleLoading.Remove($path)
    $script:pwshModuleLoaded[$path] = $true
    $null = $script:pwshModuleLoadOrder.Add($path)
}

$script:pwshModulePaths.Keys |
    Sort-Object |
    ForEach-Object {
        Resolve-PwshModuleLoadOrder -Name $_
    }

foreach ($path in $script:pwshModuleLoadOrder) {
    . $path
}

Remove-Item Function:\Get-PwshModuleDependencies, Function:\Resolve-PwshModuleLoadOrder -ErrorAction SilentlyContinue

# Starship
Invoke-Expression (&starship init powershell)
