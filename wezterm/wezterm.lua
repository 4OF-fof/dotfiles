local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

local tmux
if wezterm.target_triple:match("darwin") then
    tmux = "/opt/homebrew/bin/tmux"
else
    tmux = "tmux"
end

config.default_prog = { tmux }

config.font = wezterm.font("UDEV Gothic NF")
config.font_size = 14.0

config.color_scheme = "Tokyo Night"

config.native_macos_fullscreen_mode = true
config.enable_tab_bar = false

config.enable_scroll_bar = false
config.audible_bell = "Disabled"

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():perform_action(wezterm.action.ToggleFullScreen, pane)
end)

return config
