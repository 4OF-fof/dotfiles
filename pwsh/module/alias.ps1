if (Get-Command lsd -ErrorAction SilentlyContinue) {
    function lsd_default {
        lsd --ignore-glob nul @args
    }
    Set-Alias -Name ls -Value lsd_default
}