local wezterm = require 'wezterm'
local config = {}

local function script_dir()
  local source = debug.getinfo(1, "S").source
  local path = source:gsub("^@", "")
  return path:match("^(.*)[/\\][^/\\]+$") or "."
end

if wezterm.config_builder then
 config = wezterm.config_builder()
end
 config.color_scheme_dirs = { script_dir() .. '/themes' }
 config.window_background_opacity = 0.94
 -- config.color_scheme = 'Tiniri Dark'
 config.color_scheme = 'Pnevma'
 config.font =
     wezterm.font('JetBrains Mono', { weight = 'Bold' })
 config.font_size = 16.0
 return config
