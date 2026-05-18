---
winget: ZedIndustries.Zed
---

# Zed

Zed の設定。

## Nix

- 設定値は `nix/modules/zed.nix` に Nix attrset として定義
- macOS では `nix/modules/zed.nix` から `~/.config/zed/settings.json` を生成
- Windows では WSL NixOS の `wsl` profile から `/mnt/c/Users/fof/AppData/Roaming/Zed/settings.json` へ展開
