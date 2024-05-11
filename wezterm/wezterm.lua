local wezterm = require 'wezterm'

local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.initial_cols = 100
config.initial_rows = 30
config.font_size = 12
config.font = wezterm.font("JetBrainsMono Nerd Font")

config.color_scheme = "Dracula"
config.window_background_opacity = 0.95

config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = true

config.window_close_confirmation = 'NeverPrompt'


config.default_prog = { 'pwsh' }
config.default_cwd = "D:\\Lecter"
-- config.default_domain = 'SSH:hx90'

config.launch_menu = {
    { label = 'PowerShell', args = { 'pwsh' }, },
    { label = 'Ubuntu', args = { 'ubuntu' }, },
    { label = 'HX90', domain = { DomainName = 'SSH:hx90' }, },
}


local platform = require('platform')()
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

config.keys = {
    { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab({ confirm = false }) },
    { key = 't', mods = 'CTRL', action = act.SpawnTab('DefaultDomain') },


    { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
    { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
    { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
    -- { key = 'F4', mods = 'NONE', action = act.ShowTabNavigator },
    { key = 'F4', mods = 'NONE', action = act.SpawnCommandInNewTab({ args = { 'ubuntu' }, }) },

    { key = 'F5', mods = 'NONE', action = act.SpawnCommandInNewTab({ domain = { DomainName = 'SSH:hx90' }, }) },
    { key = 'F6', mods = 'NONE', action = act.SpawnCommandInNewTab({ domain = { DomainName = 'SSH:occc' }, }) },
    { key = 'F7', mods = 'NONE', action = act.SpawnCommandInNewTab({ domain = { DomainName = 'SSH:z790.t' },}) },
    { key = 'F8', mods = 'NONE', action = act.SpawnCommandInNewTab({ domain = { DomainName = 'SSH:a401.t' }, }) },

    { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
    { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },
}


return config
