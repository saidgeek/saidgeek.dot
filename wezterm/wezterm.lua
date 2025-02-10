local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "catppuccin-mocha"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	top = 3,
	left = 3,
	right = 3,
	bottom = 3,
}
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.initial_rows = 55
config.initial_cols = 190

config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold" })
config.font_size = 13.0

config.window_close_confirmation = "NeverPrompt"
config.enable_scroll_bar = false

return config
