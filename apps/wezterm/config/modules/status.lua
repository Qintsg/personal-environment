local wezterm = require 'wezterm'
local util = require 'modules.util'
local metrics = require 'modules.metrics'

local function segment(icon, text, fg, bg)
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = string.format(' %s  %s ', icon, text) },
  }
end

local function append(dst, src)
  for _, item in ipairs(src) do
    table.insert(dst, item)
  end
end

local function spacer(dst)
  table.insert(dst, { Text = '  ' })
end

return function(_, _)
  -- 右上角状态栏只保留当前终端、当前工具、CPU 和内存。
  wezterm.on('update-status', function(window, pane)
    local cells = {}
    local sample = metrics.sample()

    local shell = util.current_terminal_label(pane)
    if shell == 'SSH' then
      shell = util.ssh_target(pane) or shell
    end
    append(cells, segment(
      util.icon_for_label(util.current_terminal_label(pane)),
      shell,
      '#D7E3FC',
      '#25324A'
    ))

    local activity = util.current_activity_label(pane)
    if activity then
      spacer(cells)
      append(cells, segment(
        util.icon_for_label(activity),
        activity,
        '#DDEBFF',
        '#2E3F63'
      ))
    end

    local cpu = metrics.cpu_text(sample)
    if cpu then
      spacer(cells)
      append(cells, segment(
        util.pick_icon({ 'md_cpu_64_bit', 'cod_dashboard' }, 'CPU'),
        cpu,
        '#FBD38D',
        '#4A3320'
      ))
    end

    local memory = metrics.memory_text(sample)
    if memory then
      spacer(cells)
      append(cells, segment(
        util.pick_icon({ 'md_memory', 'cod_database' }, 'MEM'),
        memory,
        '#D6BCFA',
        '#3E3154'
      ))
    end

    window:set_right_status(wezterm.format(cells))
  end)
end

