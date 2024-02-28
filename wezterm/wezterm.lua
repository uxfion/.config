local wezterm = require('wezterm')
local config = {
  font_size = 15,
  font = wezterm.font(
    "JetBrainsMono Nerd Font",
    { weight = "Regular" }
  ),
  color_scheme = "Dracula",
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  -- window_decorations = "NONE",
  show_new_tab_button_in_tab_bar = false,
  window_background_opacity = 0.9,
  macos_window_background_blur = 70,
  enable_kitty_graphics = true,
}

return config
