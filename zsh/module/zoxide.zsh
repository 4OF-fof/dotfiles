# deps:

eval "$(zoxide init zsh)"

function _z_expand_before_accept() {
  emulate -L zsh

  local line="$BUFFER"

  if [[ "$line" == z\ * || "$line" == zi\ * ]]; then
    local cmd rest dest
    cmd="${line%% *}"
    rest="${line#* }"

    if [[ "$cmd" == "z" ]]; then
      dest="$(zoxide query -- ${=rest} 2>/dev/null)" || return 0
    else
      return 0
    fi

    if [[ "$dest" == "$HOME" ]]; then
      BUFFER='cd ~'
    elif [[ "$dest" == "$HOME"/* ]]; then
      local suffix="${dest#$HOME}"
      BUFFER="cd ~${(q)suffix}"
    else
      BUFFER="cd ${(q)dest}"
    fi

    CURSOR=${#BUFFER}
  fi

  zle .accept-line
}

zle -N accept-line _z_expand_before_accept
