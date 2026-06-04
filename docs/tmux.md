---
links:
  - source: tmux/.tmux.conf
    target: ~/.tmux.conf
  - source: tmux/module
    target: ~/tmux
brew: tmux
---

# Memo
windows側はwslのtmuxを使用

# Tmux

ターミナルマルチプレクサーの設定。

## .tmux.conf

- マウス操作を有効化
- ステータスバーを表示
- `~/tmux/theme.conf` をソースとして読み込み

## module/theme.conf

カスタムカラーテーマとステータスバー設定。

- ステータスバーをトップに配置
- 左側: セッション名とウィンドウ名
- 中央: カスタムコマンド出力
- 右側: 時刻（`%H:%M`）
