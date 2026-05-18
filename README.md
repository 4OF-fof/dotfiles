Mac(nix-darwin + Home Manager)
```sh
nix run nix-darwin/master#darwin-rebuild --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#mac
```

Windows(WSL NixOS + Home Manager)
```sh
nix run home-manager/master -- switch --flake .#wsl
```

Windows 上の設定ファイルは WSL の NixOS から `/mnt/c/Users/fof/...` へ展開します。

brew(scoop)非対応

Vite+
```sh
curl -fsSL https://vite.plus | bash
```
