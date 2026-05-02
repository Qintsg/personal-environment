return function(wezterm, config)
  -- 主题名称：Fluent Terminal Dark
  -- 参考方向：
  -- 1. Windows Terminal 的深色中性材质感和更实的顶部框架
  -- 2. 文章里提到的 WezTerm 背景模糊思路，本质上还是官方的 win32_system_backdrop
  -- 3. 官方文档建议 Mica/Tabbed 在 Windows 上搭配 window_background_opacity = 0 使用

  -- 更接近 Windows Terminal 的 Win11 风格。
  -- 比起 Acrylic，它更稳，也更不容易出现偏白雾感。
  config.win32_system_backdrop = 'Tabbed'

  -- 按官方建议把系统背景层交给 Windows 本身。
  config.window_background_opacity = 0
  config.text_background_opacity = 0

  -- 不用纯色实心背景，改成深色中性蒙版 + 极轻微冷色染层。
  -- 这样能保留毛玻璃，同时不至于把内容区洗白。
  config.background = {
    {
      source = {
        Color = '#080c12',
      },
      width = '100%',
      height = '100%',
      opacity = 0.42,
    },
    {
      source = {
        Gradient = {
          colors = { '#10161f', '#141b24', '#0d131b' },
          orientation = { Linear = { angle = -12.0 } },
        },
      },
      width = '100%',
      height = '100%',
      opacity = 0.36,
    },
    {
      source = {
        Gradient = {
          colors = { '#1a2430', '#0d1218' },
          orientation = {
            Radial = {
              cx = 0.72,
              cy = 0.16,
              radius = 1.00,
            },
          },
        },
      },
      width = '100%',
      height = '100%',
      opacity = 0.03,
    },
  }

  -- 颜色参考 Windows Terminal 的深色中性底：
  -- 主背景接近炭灰蓝，强调色保留冷蓝。
  config.colors = {
    foreground = '#F3F3F3',
    background = '#0d1218',
    cursor_bg = '#4CC2FF',
    cursor_fg = '#101010',
    cursor_border = '#4CC2FF',

    selection_fg = '#FFFFFF',
    selection_bg = '#5A5A5A',

    scrollbar_thumb = '#3A3A3A',
    split = '#2D3440',
    compose_cursor = '#4CC2FF',

    ansi = {
      '#1E1E1E',
      '#E56B6F',
      '#6CCB5F',
      '#D7BA7D',
      '#61AFEF',
      '#C678DD',
      '#56B6C2',
      '#D4D4D4',
    },

    brights = {
      '#6B6B6B',
      '#F28B8D',
      '#8AD47E',
      '#EFD28A',
      '#7CC7FF',
      '#D9A7F0',
      '#7FDDE6',
      '#FFFFFF',
    },

    tab_bar = {
      background = 'rgba(13, 17, 23, 0.80)',
      active_tab = {
        bg_color = 'rgba(20, 27, 39, 0.85)',
        fg_color = '#FFFFFF',
        intensity = 'Bold',
      },
      inactive_tab = {
        bg_color = 'rgba(11, 15, 21, 0.72)',
        fg_color = '#AEB7C7',
      },
      inactive_tab_hover = {
        bg_color = 'rgba(23, 29, 41, 0.82)',
        fg_color = '#F3F3F3',
      },
      new_tab = {
        bg_color = 'rgba(11, 15, 21, 0.72)',
        fg_color = '#AEB7C7',
      },
      new_tab_hover = {
        bg_color = 'rgba(27, 34, 48, 0.82)',
        fg_color = '#FFFFFF',
      },
    },
  }

  -- 顶栏和标签栏更实一些，模仿 Windows Terminal 那种框架与内容分层。
  config.window_frame = {
    font = wezterm.font({ family = 'Segoe UI', weight = 'Bold' }),
    font_size = 11.5,
    active_titlebar_bg = 'rgba(12, 16, 22, 0.78)',
    inactive_titlebar_bg = 'rgba(9, 13, 19, 0.69)',
  }
end

