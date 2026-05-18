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

- `nix/modules/git.nix` で Home Manager の `programs.git.settings` を設定
- user.name / user.email を設定
- デフォルトブランチを master に設定
- `.env` をグローバル ignore に設定
- Windows 用の `core.sshCommand` は Nix の hostPlatform 分岐で設定
