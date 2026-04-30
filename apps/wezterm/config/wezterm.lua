local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local fonts = require 'modules.fonts'

-- 鍏佽浠庡綋鍓嶉厤缃洰褰曠洿鎺?require 鑷畾涔夋ā鍧椼€?package.path = package.path
    .. ';' .. wezterm.config_dir .. '/?.lua'
    .. ';' .. wezterm.config_dir .. '/?/init.lua'

fonts.register_prompt(wezterm)

require('modules.theme')(wezterm, config)
require('modules.ui')(wezterm, config)
require('modules.nvim_dashboard')(wezterm, config)
require('modules.launch')(wezterm, config)
require('modules.keys')(wezterm, config)
require('modules.status')(wezterm, config)
require('modules.tabs')(wezterm, config)

return config

