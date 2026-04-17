# deps:

if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    return
}

Import-Module PSReadLine

function Test-IsWezTermPsmuxSession {
    $inTmux = -not [string]::IsNullOrEmpty($env:TMUX)
    $inWezTerm = (
        -not [string]::IsNullOrEmpty($env:WEZTERM_EXECUTABLE) -or
        -not [string]::IsNullOrEmpty($env:WEZTERM_PANE) -or
        $env:TERM_PROGRAM -eq 'WezTerm'
    )

    return $inTmux -and $inWezTerm
}

if (Test-IsWezTermPsmuxSession) {
    $disablePasteHandler = {
        param($key, $arg)
    }

    Set-PSReadLineKeyHandler -Chord Ctrl+v -BriefDescription 'Disable paste in WezTerm psmux session' -ScriptBlock $disablePasteHandler
}

Remove-Item Function:\Test-IsWezTermPsmuxSession -ErrorAction SilentlyContinue
