local profiles = require 'modules.profiles'

return function(wezterm, config)
  local act = wezterm.action
  local loaded = profiles.apply(config)

  -- 右键标签栏的加号时，只显示用户自定义终端列表，不使用 WezTerm 默认 Launcher。
  wezterm.on('new-tab-button-click', function(window, pane, button)
    if button ~= 'Right' then
      return
    end

    local choices = {}
    for _, profile in ipairs(loaded.profiles or {}) do
      table.insert(choices, {
        id = profile.id,
        label = profile.menu_label,
      })
    end

    window:perform_action(
      act.InputSelector({
        title = '选择要打开的终端',
        choices = choices,
        action = wezterm.action_callback(function(inner_window, inner_pane, id)
          if not id then
            return
          end

          for _, profile in ipairs((profiles.get().profiles or {})) do
            if profile.id == id then
              inner_window:perform_action(
                act.SpawnCommandInNewTab(profile.spawn),
                inner_pane
              )
              break
            end
          end
        end),
      }),
      pane
    )

    return false
  end)
end

