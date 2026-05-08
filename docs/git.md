---
links:
  - source: git/.gitconfig
    target: ~/.gitconfig
  - source: git/.gitignore_global
    target: ~/.gitignore_global
brew:
  - git
  - gh
scoop:
  - source: main
    name: git
  - source: main
    name: gh
---

# Git

Gitのグローバル設定。

## .gitconfig

- user.name / user.email を 設定
- デフォルトブランチを master に設定
- core.excludesFile でグローバルな gitignore を参照

## .gitignore_global

全リポジトリ共通で無視したいファイルを定義。

- `.env` — 環境変数ファイル
