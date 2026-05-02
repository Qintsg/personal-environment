local util = require 'modules.util'

return function(wezterm, config)
  local act = wezterm.action

  config.keys = {
    -- 常用复制粘贴。
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

    -- Ctrl+C：有选区时复制，否则透传给前台程序。
    {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
        local has_selection = window:get_selection_text_for_pane(pane) ~= ''
        if has_selection then
          window:perform_action(act.CopyTo('Clipboard'), pane)
          window:perform_action(act.ClearSelection, pane)
        else
          window:perform_action(act.SendKey({ key = 'c', mods = 'CTRL' }), pane)
        end
      end),
    },
    { key = 'v', mods = 'CTRL',        action = act.PasteFrom('Clipboard') },

    -- 新建标签页时回到用户主目录。
    {
      key = 't',
      mods = 'CTRL',
      action = act.SpawnCommandInNewTab({
        cwd = wezterm.home_dir,
      }),
    },

    -- 关闭标签页时不再二次确认。
    { key = 'w', mods = 'CTRL',        action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'CTRL',        action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'CTRL|SHIFT',  action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'CTRL|SHIFT',  action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'SUPER',       action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },

    -- 搜索当前选中内容；未选中时打开空搜索。
    { key = 'f', mods = 'CTRL',        action = act.Search('CurrentSelectionOrEmptyString') },

    -- 手动设置当前标签页标题，优先级高于自动标题。
    {
      key = 'e',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine({
        description = '请输入当前标签页标题，留空表示清除手动标题',
        action = wezterm.action_callback(function(window, _, line)
          if line ~= nil then
            local tab = window:active_tab()
            util.set_manual_tab_title(tab, line)
            tab:set_title(line)
          end
        end),
      }),
    },
    {
      key = 'Backspace',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(function(window, _)
        local tab = window:active_tab()
        util.set_manual_tab_title(tab, '')
        tab:set_title('')
      end),
    },

    -- 标签页切换。
    { key = 'Tab',        mods = 'CTRL',       action = act.ActivateTabRelative(1) },
    { key = 'Tab',        mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'LeftArrow',  mods = 'ALT',        action = act.ActivateTabRelative(-1) },
    { key = 'RightArrow', mods = 'ALT',        action = act.ActivateTabRelative(1) },
  }
end

