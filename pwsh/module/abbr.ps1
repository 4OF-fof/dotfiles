# deps: alias abbr.core

if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Register-Abbr -Name 'la' -Expansion 'ls -la'
}
