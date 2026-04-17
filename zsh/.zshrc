# Sheldon (plugin manager)
eval "$(sheldon source)"

# Module
typeset -gA _zsh_module_paths _zsh_module_loading _zsh_module_loaded

for f in ~/.zsh_module/*.zsh(N); do
  _zsh_module_paths[${f:t:r}]="${f:A}"
done

zsh_module_dependencies() {
  local file=$1 line
  reply=()

  while IFS= read -r line; do
    [[ $line == '# deps:'* ]] || continue
    line=${line#\# deps:}
    reply=(${(z)line})
    return 0
  done < "$file"
}

load_zsh_module() {
  local module_name=$1
  local file=${_zsh_module_paths[$module_name]}
  local dep

  if [[ -z $file ]]; then
    print -u2 -- "zsh module dependency not found: $module_name"
    return 1
  fi

  [[ -n ${_zsh_module_loaded[$file]} ]] && return 0

  if [[ -n ${_zsh_module_loading[$file]} ]]; then
    print -u2 -- "circular zsh module dependency detected: $module_name"
    return 1
  fi

  _zsh_module_loading[$file]=1

  zsh_module_dependencies "$file"
  for dep in "${reply[@]}"; do
    load_zsh_module "$dep" || return 1
  done

  source "$file"

  unset "_zsh_module_loading[$file]"
  _zsh_module_loaded[$file]=1
}

for module_name in ${(on)${(k)_zsh_module_paths}}; do
  load_zsh_module "$module_name" || return 1
done

unfunction zsh_module_dependencies load_zsh_module
unset module_name f

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# Starship
eval "$(starship init zsh)"
