# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# Sheldon plugin manager
eval "$(sheldon source)"

# Module
for f in ~/.zsh_module/*.zsh; do
  source "$f"
done
