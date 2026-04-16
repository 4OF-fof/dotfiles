if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    return
}

if (-not $script:abbr_map) {
    $script:abbr_map = @{}
}

function Register-Abbr {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Expansion
    )

    $script:abbr_map[$Name] = $Expansion
}

function Expand-Abbr {
    param(
        [switch]$AcceptLine
    )

    $line = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $prefix = $line.Substring(0, $cursor)
    $match = [regex]::Match($prefix, '(?<!\S)(\S+)$')

    if ($match.Success) {
        $name = $match.Groups[1].Value

        if ($script:abbr_map.ContainsKey($name)) {
            $start = $cursor - $name.Length
            $expansion = $script:abbr_map[$name]
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($start, $name.Length, $expansion)
        }
    }

    if ($AcceptLine) {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        return
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}

Set-PSReadLineKeyHandler -Key Spacebar -BriefDescription 'Expand abbreviation' -ScriptBlock {
    Expand-Abbr
}

Set-PSReadLineKeyHandler -Key Enter -BriefDescription 'Expand abbreviation and accept line' -ScriptBlock {
    Expand-Abbr -AcceptLine
}
