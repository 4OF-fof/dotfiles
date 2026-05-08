---
links:
  - source: zsh/.zshrc
    target: ~/.zshrc
    host: ["mac"]
  - source: zsh/.zprofile
    target: ~/.zprofile
    host: ["mac"]
  - source: zsh/module
    target: ~/.zsh_module
    host: ["mac"]
  - source: zsh/sheldon/plugins.toml
    target: ~/.config/sheldon/plugins.toml
    host: ["mac"]
brew: sheldon
---

# Zsh

Zsh の設定ファイル。macOS 環境で使用。

## .zshrc

- Sheldon プラグインマネージャーの読み込み
- カスタムモジュールシステムの実装（依存関係解決付き）
- Vite+ の環境設定読み込み
- Starship の有効化

## sheldon/plugins.toml

使用プラグイン:

- `zsh-autosuggestions` — 履歴ベースの入力候補表示
- `fast-syntax-highlighting` — 構文ハイライト
- `zsh-abbr` — 略語展開機能

## module/

依存関係解決機能付きのモジュールシステム。各 `.zsh` ファイルは先頭コメントで依存を宣言できる。

- `alias.zsh` — `lsd` があれば `ls` エイリアスを設定
- `abbr.zsh` — `la` などの略語を登録（`alias` に依存）
- `abbr.highlight.zsh` — 略語のシンタックスハイライト対応（`abbr` に依存）
- `zoxide.zsh` — `zoxide` の初期化と `z` / `zi` コマンドの展開処理
