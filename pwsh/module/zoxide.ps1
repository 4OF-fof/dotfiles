# deps: abbr.core

if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
    return
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

$global:__zoxide_previous_starship_precommand = $null
if (Test-Path Function:\Invoke-Starship-PreCommand) {
    $global:__zoxide_previous_starship_precommand = ${function:Invoke-Starship-PreCommand}.GetNewClosure()
}

function global:Invoke-Starship-PreCommand {
    if ($null -ne $global:__zoxide_previous_starship_precommand) {
        & $global:__zoxide_previous_starship_precommand
    }

    $null = __zoxide_hook
}

function ConvertTo-PwshSingleQuotedString {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    return "'{0}'" -f ($Value -replace "'", "''")
}

function ConvertTo-PwshBarewordPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    return ($Value -replace '`', '``' -replace '([ "#$'',;(){}\[\]|&<>@])', '`$1')
}

function Format-ZoxideLocationCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $homePath = [System.IO.Path]::GetFullPath($HOME).TrimEnd('\', '/')
    $targetPath = [System.IO.Path]::GetFullPath($Path)

    if ($targetPath.Equals($homePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return 'cd ~'
    }

    $homePrefix = '{0}{1}' -f $homePath, [System.IO.Path]::DirectorySeparatorChar
    if ($targetPath.StartsWith($homePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $suffix = $targetPath.Substring($homePrefix.Length).Replace('\', '/')
        return "cd ~/{0}" -f (ConvertTo-PwshBarewordPath -Value $suffix)
    }

    return "cd $(ConvertTo-PwshSingleQuotedString -Value $targetPath)"
}

function Resolve-ZoxideAcceptLineCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    $errors = $null
    $tokens = [System.Management.Automation.PSParser]::Tokenize($Line, [ref]$errors)

    if ($errors.Count -gt 0 -or $tokens.Count -lt 2) {
        return $null
    }

    $command = $tokens[0].Content
    if ($command -eq 'zi') {
        return $null
    }

    if ($command -ne 'z') {
        return $null
    }

    $arguments = @(
        $tokens |
            Select-Object -Skip 1 |
            Where-Object { $_.Type -in @('CommandArgument', 'String') } |
            ForEach-Object { $_.Content }
    )

    if ($arguments.Count -eq 0) {
        return $null
    }

    $currentDirectory = __zoxide_pwd
    if ($null -ne $currentDirectory) {
        $destination = @(__zoxide_bin query --exclude $currentDirectory "--" @arguments 2>$null) | Select-Object -First 1
    }
    else {
        $destination = @(__zoxide_bin query "--" @arguments 2>$null) | Select-Object -First 1
    }

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($destination)) {
        return $null
    }

    return Format-ZoxideLocationCommand -Path $destination.Trim()
}

Set-PSReadLineKeyHandler -Key Enter -BriefDescription 'Expand zoxide and accept line' -ScriptBlock {
    $line = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $command = Resolve-ZoxideAcceptLineCommand -Line $line
    if ($null -ne $command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $command)
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }

    Expand-Abbr -AcceptLine
}
