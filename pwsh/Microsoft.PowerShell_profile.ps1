# Module
Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot "module") -Filter *.ps1 -ErrorAction SilentlyContinue |
    Sort-Object -Property Name |
    ForEach-Object {
        . $_.FullName
    }