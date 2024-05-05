local wezterm = require 'wezterm'

local c = {}
if wezterm.config_builder then
    c = wezterm.config_builder()
  end

-- 初始大小
c.initial_cols = 100
c.initial_rows = 30

-- 关闭时不进行确认
c.window_close_confirmation = 'NeverPrompt'

c.font_size = 12
c.font = wezterm.font("JetBrainsMono Nerd Font")

c.color_scheme = "Dracula"

-- 透明背景
c.window_background_opacity = 0.95

c.use_fancy_tab_bar = true


c.default_prog = { 'pwsh' }
c.default_cwd = "D:\\Lecter"
-- c.default_domain = 'WSL:Ubuntu'

-- 启动菜单的一些启动项
c.launch_menu = {
  { label = 'PowerShell', args = { 'pwsh' }, },
  { label = 'Ubuntu', args = { 'ubuntu' }, },

--   { label = 'nas / ssh',       args = { 'C:/msys64/usr/bin/ssh.exe', 'nas' }, },
--   { label = 'MINGW64 / MSYS2', args = { 'C:/msys64/msys2_shell.cmd', '-defterm', '-here', '-no-start', '-shell', 'zsh', '-mingw64' }, },
--   { label = 'MSYS / MSYS2',    args = { 'C:/msys64/msys2_shell.cmd', '-defterm', '-here', '-no-start', '-shell', 'zsh', '-msys' }, },
}


return c
