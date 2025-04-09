local wezterm = require 'wezterm'

local config = {}
if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.exit_behavior = "Hold"
config.window_close_confirmation = 'NeverPrompt'

config.color_scheme = "Catppuccin Mocha"
config.initial_cols = 100
config.initial_rows = 30
config.font_size = 13
config.font = wezterm.font("JetBrainsMonoNL Nerd Font", { weight = "Regular" })

config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95


config.default_prog = { 'pwsh' }

config.launch_menu = {
    { label = 'PowerShell', args = { 'pwsh' }, },
    { label = 'Ubuntu', args = { 'ubuntu' }, },
}


local act = wezterm.action

config.keys = {
    { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab({ confirm = false }) },
    { key = 't', mods = 'CTRL', action = act.SpawnTab('DefaultDomain') },

    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            selection_text = window:get_selection_text_for_pane(pane)
            is_selection_active = string.len(selection_text) ~= 0
            if is_selection_active then
                window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
            else
                window:perform_action(act.SendKey{ key='c', mods='CTRL' }, pane)
            end
        end),
    },
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

    { key = 'F1', mods = 'NONE', action = act.ActivateCommandPalette },
    { key = 'F2', mods = 'NONE', action = act.ShowLauncher },
    { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
}


return config
