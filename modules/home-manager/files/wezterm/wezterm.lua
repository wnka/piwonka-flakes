-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font 'Cascadia Code NF'
config.font_size = 16.0
config.line_height = 1.2
config.hide_tab_bar_if_only_one_tab = true
-- disable ligatures, I don't like that stuff
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- For emacs undo passthrough
config.keys = {
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
}

-- config.debug_key_events = true

-- For example, changing the color scheme:
config.color_scheme = 'Tokyo Night Storm'

-- and finally, return the configuration to wezterm
return config