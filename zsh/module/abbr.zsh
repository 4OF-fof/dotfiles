# deps: alias

if (( $+commands[lsd] )); then
  abbr --force --quieter la='ls -la'
fi
