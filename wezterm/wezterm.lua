local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:match("darwin") ~= nil
local tmux = is_mac and "/opt/homebrew/bin/tmux" or "tmux"

config.default_prog = { tmux }

config.font = wezterm.font("UDEV Gothic NF")

config.colors = {
  foreground = '#d6e0fc',
  background = '#222436',
  cursor_bg = '#d6e0fc',
  cursor_fg = '#222436',
  cursor_border = '#d6e0fc',
  selection_fg = '#d6e0fc',
  selection_bg = '#46466a',
  scrollbar_thumb = '#46466a',
  split = '#46466a',
  ansi = {
    '#202030',
    '#ff5775',
    '#c7ff80',
    '#ffbb5b',
    '#8ab0ff',
    '#bb91ff',
    '#71dfff',
    '#a5a5cc',
  },
  brights = {
    '#46466a',
    '#ff5775',
    '#c7ff80',
    '#ffbb5b',
    '#8ab0ff',
    '#bb91ff',
    '#71dfff',
    '#ffffff',
  },
}

config.native_macos_fullscreen_mode = is_mac
config.enable_tab_bar = false
config.disable_default_key_bindings = true
config.keys = {
    { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
    { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
}

config.enable_scroll_bar = false
config.audible_bell = "Disabled"

-- 起動時フルスクリーン/dpiでフォントサイズ変更
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    local gui_window = window:gui_window()
    gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
    local dims = gui_window:get_dimensions()

    local font_size = 12
    if dims and dims.dpi and dims.dpi > 120 then
        font_size = 14
    end

    gui_window:set_config_overrides({
        font_size = font_size
    })
end)

return config
