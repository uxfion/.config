local wezterm = require 'wezterm'

local config = {
  initial_cols = 110,
  initial_rows = 40,
  font_size = 12,
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


config.default_prog = { 'C:/Users/Lecter/AppData/Local/Microsoft/WindowsApps/Microsoft.PowerShell_8wekyb3d8bbwe/pwsh.exe' }

-- -- 启动菜单的一些启动项
-- config.launch_menu = {
--   { label = 'MINGW64 / MSYS2', args = { 'C:/msys64/msys2_shell.cmd', '-defterm', '-here', '-no-start', '-shell', 'zsh', '-mingw64' }, },
--   { label = 'MSYS / MSYS2',    args = { 'C:/msys64/msys2_shell.cmd', '-defterm', '-here', '-no-start', '-shell', 'zsh', '-msys' }, },
--   { label = 'PowerShell',      args = { 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' }, },
--   { label = 'CMD',             args = { 'cmd.exe' }, },
--   { label = 'nas / ssh',       args = { 'C:/msys64/usr/bin/ssh.exe', 'nas' }, },
-- }


return config
