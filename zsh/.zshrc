# Sheldon (plugin manager)
eval "$(sheldon source)"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# Starship
eval "$(starship init zsh)"

# bun completions
[ -s "/Users/mukai/.bun/_bun" ] && source "/Users/mukai/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
