---
scoop:
  - source: main
    name: git
  - source: main
    name: gh
  - source: extras
    name: lazygit
---

# Git

Gitのグローバル設定。

## Nix

- `nix/modules/apps/git.nix` で Home Manager の `programs.git.settings` を設定
- user.name / user.email を設定
- デフォルトブランチを master に設定
- `.env` をグローバル ignore に設定
- Windows 用の `core.sshCommand` は `dotfiles.git.windowsSettings` で共通設定に追加
