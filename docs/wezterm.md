---
links:
  - source: wezterm/wezterm.lua
    target: ~/.config/wezterm/wezterm.lua
cask: wezterm
winget: wez.wezterm
---

# WezTerm

ターミナルエミュレータ設定。

## wezterm.lua

- デフォルトプログラムとして `tmux` を起動（macOS では Homebrew パス）
- フォント: `UDEV Gothic NF`
- タブバー無効化
- デフォルトキーバインド無効化（`Cmd+C` / `Cmd+V` のみ有効）
- 起動時に自動フルスクリーン化
- DPI に応じたフォントサイズ自動調整（>120dpi で 14pt）
