---
---

# PowerShell

Windows 環境での PowerShell 設定。

WSL の NixOS から `wsl` profile を適用し、`/mnt/c/Users/fof/Documents/PowerShell` へ展開する。

## Microsoft.PowerShell_profile.ps1

- カスタムモジュールシステムの実装（依存関係解決付き）
- Starship の有効化

## module/

依存関係解決機能付きのモジュールシステム。各 `.ps1` ファイルは先頭コメントで依存を宣言できる。

- `alias.ps1` — エイリアスを設定
- `abbr.ps1` — `la` などの略語を登録（`alias` / `abbr.core` に依存）
- `abbr.core.ps1` — abbr実装
- `terminal.compat.ps1` — ターミナル依存の不具合解決
- `zoxide.ps1` — `zoxide` の初期化・履歴への展開
