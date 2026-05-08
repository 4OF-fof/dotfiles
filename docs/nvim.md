---
links:
  - source: nvim
    target: ~/.config/nvim
    windows:
      target: ~/AppData/Local/nvim
brew: neovim
scoop:
  source: main
  name: neovim
---

# Neovim

Neovim の設定。`lazy.nvim` をプラグインマネージャーとして使用。

## init.lua

設定のエントリーポイント。`config.lazy` の読み込みのみを行う。

## lua/config/lazy.lua

- `lazy.nvim` のブートストラップ（未インストール時に自動クローン）

## lua/plugins/

- `init.lua` — プラグインモジュールのインポート設定
- `which-key.lua` — キーマップの表示支援
- `noice.lua` — UI 強化（コマンドライン・通知など）
- `snacks.lua` — 各種ユーティリティプラグイン
