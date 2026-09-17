local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

local color_scheme_dirs = {
  wezterm.config_dir .. '/themes',
}

local home = os.getenv 'HOME'
if home then
  table.insert(color_scheme_dirs, home .. '/git/dotfiles/terminal/wezterm/themes')
end

config.color_scheme_dirs = color_scheme_dirs
config.window_background_opacity = 0.90
config.color_scheme = 'Pnevma'
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })
config.font_size = 16.0

config.window_decorations = 'RESIZE'
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

local unfocused_text = { hue = 1.0, saturation = 0.25, brightness = 0.55 }
local unfocused_opacity = 0.72

local function same_hsb(actual, expected)
  if actual == nil or expected == nil then
    return actual == expected
  end

  return actual.hue == expected.hue
    and actual.saturation == expected.saturation
    and actual.brightness == expected.brightness
end

wezterm.on('window-focus-changed', function(window)
  local overrides = window:get_config_overrides() or {}
  local text_hsb
  local opacity

  if not window:is_focused() then
    text_hsb = unfocused_text
    opacity = unfocused_opacity
  end

  if same_hsb(overrides.foreground_text_hsb, text_hsb)
    and overrides.window_background_opacity == opacity then
    return
  end

  overrides.foreground_text_hsb = text_hsb
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

return config
