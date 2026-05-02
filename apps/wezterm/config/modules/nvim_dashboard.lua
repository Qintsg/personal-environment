return function(wezterm, config)
  local target = tostring(wezterm.target_triple or ''):lower()

  config.window_padding = {
    left = 18,
    right = 18,
    top = 12,
    bottom = 10,
  }

  config.window_background_opacity = 0.88
  config.text_background_opacity = 1.0

  if target:find('windows', 1, true) then
    -- See wezterm docs: win32_system_backdrop works with window_background_opacity < 1.0.
    config.win32_system_backdrop = 'Acrylic'
  elseif target:find('apple', 1, true) then
    config.macos_window_background_blur = 20
  end

  config.colors = config.colors or {}
  config.colors.background = '#171b22'
  config.colors.cursor_bg = '#d85858'
  config.colors.cursor_border = '#d85858'
  config.colors.selection_bg = '#3f4756'
  config.colors.scrollbar_thumb = '#313847'
  config.colors.split = '#2a3040'

  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.background = '#191d26'
  config.colors.tab_bar.active_tab = {
    bg_color = '#252b36',
    fg_color = '#f3e5c4',
    intensity = 'Bold',
  }
  config.colors.tab_bar.inactive_tab = {
    bg_color = '#1b202a',
    fg_color = '#8c96a8',
  }
  config.colors.tab_bar.inactive_tab_hover = {
    bg_color = '#232936',
    fg_color = '#d9dde7',
  }
  config.colors.tab_bar.new_tab = {
    bg_color = '#1b202a',
    fg_color = '#7dc4e4',
  }
  config.colors.tab_bar.new_tab_hover = {
    bg_color = '#252b36',
    fg_color = '#f3e5c4',
  }

  config.window_frame = config.window_frame or {}
  config.window_frame.active_titlebar_bg = '#191d26'
  config.window_frame.inactive_titlebar_bg = '#151920'
end

