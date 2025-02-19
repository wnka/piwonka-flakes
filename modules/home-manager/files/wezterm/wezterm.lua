-- Pull in the wezterm API
local wezterm = require 'wezterm'

--- https://blog.gripdev.xyz/2025/01/08/wezterm-easily-copy-text-or-send-notifications-to-local-machine-even-when-connected-via-ssh/
wezterm.on('user-var-changed', function(window, pane, name, value)
  wezterm.log_info('var', name, value)
  if name == 'wez_copy' then
    window:copy_to_clipboard(value, 'Clipboard')
  end
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font({ family = 'Berkeley Mono' })
config.font_size = 14.0
config.line_height = 1.1
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- For emacs undo passthrough
config.keys = {
  { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
}

-- config.debug_key_events = true

config.color_scheme = "Tokyo Night Storm"
-- and finally, return the configuration to wezterm
return config
