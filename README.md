Mac(nix-darwin + Home Manager)
```sh
nix run nix-darwin/master#darwin-rebuild --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#mac
```

ユーザ名を一時的に上書きする場合:
```sh
DOTFILES_USER=hoge nix run nix-darwin/master#darwin-rebuild --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#mac --impure
```

Windows(WSL NixOS + Home Manager)
```sh
sudo nixos-rebuild switch --flake .#wsl
```

ユーザ名を一時的に上書きする場合:
```sh
DOTFILES_USER=mukai sudo --preserve-env=DOTFILES_USER nixos-rebuild switch --flake .#wsl --impure
```

Windows 上の設定ファイルは WSL の NixOS から `/mnt/c/Users/<Windowsユーザ名>/...` へ展開します。
