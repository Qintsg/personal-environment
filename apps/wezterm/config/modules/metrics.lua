local wezterm = require 'wezterm'

local M = {}

local state = {
  os = nil,
  cache = nil,
  last_sample_ms = 0,
  linux_cpu = nil,
}

local function now_ms()
  return math.floor(os.time() * 1000)
end

local function detect_os()
  if state.os then
    return state.os
  end

  local triple = tostring(wezterm.target_triple or ''):lower()
  if package.config:sub(1, 1) == '\\' or triple:find('windows', 1, true) then
    state.os = 'windows'
  elseif triple:find('darwin', 1, true) or triple:find('apple', 1, true) then
    state.os = 'macos'
  else
    state.os = 'linux'
  end

  return state.os
end

local function sample_interval_ms()
  if detect_os() == 'linux' then
    return 3000
  end

  return 10000
end

local function read_file(path)
  local handle = io.open(path, 'rb')
  if not handle then
    return nil
  end

  local content = handle:read('*a')
  handle:close()
  return content
end

local function run_child(args)
  local ok, stdout, stderr = wezterm.run_child_process(args)
  if not ok then
    if stderr and stderr ~= '' then
      wezterm.log_warn('绯荤粺鎸囨爣鍛戒护鎵ц澶辫触锛? .. stderr)
    end
    return nil
  end

  return stdout
end

local function parse_key_value_lines(text)
  local result = {}
  for line in (text or ''):gmatch('[^\r\n]+') do
    local key, value = line:match('^([%w_]+)=(.+)$')
    if key then
      result[key] = value
    end
  end
  return result
end

local function human_bytes(bytes)
  if not bytes then
    return nil
  end

  local units = { 'B', 'KB', 'MB', 'GB', 'TB' }
  local value = tonumber(bytes) or 0
  local unit_index = 1

  while value >= 1024 and unit_index < #units do
    value = value / 1024
    unit_index = unit_index + 1
  end

  if unit_index <= 2 then
    return string.format('%.0f%s', value, units[unit_index])
  end

  return string.format('%.1f%s', value, units[unit_index])
end

local function collect_windows()
  local script = table.concat({
    "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8",
    "$cpu=[math]::Round((Get-Counter '\\Processor(_Total)\\% Processor Time').CounterSamples[0].CookedValue,1)",
    "$os=Get-CimInstance Win32_OperatingSystem",
    "$memTotal=[double]$os.TotalVisibleMemorySize*1024",
    "$memFree=[double]$os.FreePhysicalMemory*1024",
    "$memUsed=$memTotal-$memFree",
    "Write-Output ('CPU=' + $cpu)",
    "Write-Output ('MEM_USED=' + [math]::Round($memUsed))",
    "Write-Output ('MEM_TOTAL=' + [math]::Round($memTotal))",
  }, '; ')

  local stdout = run_child({
    'powershell.exe',
    '-NoLogo',
    '-NoProfile',
    '-NonInteractive',
    '-WindowStyle',
    'Hidden',
    '-Command',
    script,
  })

  local parsed = parse_key_value_lines(stdout)
  return {
    cpu = tonumber(parsed.CPU),
    mem_used = tonumber(parsed.MEM_USED),
    mem_total = tonumber(parsed.MEM_TOTAL),
  }
end

local function parse_linux_cpu()
  local stat = read_file('/proc/stat')
  if not stat then
    return nil
  end

  local line = stat:match('cpu%s+([^\n]+)')
  if not line then
    return nil
  end

  local values = {}
  for value in line:gmatch('%S+') do
    table.insert(values, tonumber(value) or 0)
  end

  local total = 0
  for _, value in ipairs(values) do
    total = total + value
  end

  local idle = (values[4] or 0) + (values[5] or 0)
  return total, idle
end

local function parse_linux_memory()
  local meminfo = read_file('/proc/meminfo')
  if not meminfo then
    return nil, nil
  end

  local total = tonumber(meminfo:match('MemTotal:%s+(%d+)'))
  local available = tonumber(meminfo:match('MemAvailable:%s+(%d+)'))
  if not total or not available then
    return nil, nil
  end

  total = total * 1024
  local used = total - available * 1024
  return used, total
end

local function collect_linux()
  local cpu_total, cpu_idle = parse_linux_cpu()
  local cpu = nil
  if cpu_total and cpu_idle and state.linux_cpu then
    local total_delta = cpu_total - state.linux_cpu.total
    local idle_delta = cpu_idle - state.linux_cpu.idle
    if total_delta > 0 then
      cpu = math.max(0, math.min(100, (1 - idle_delta / total_delta) * 100))
    end
  end
  state.linux_cpu = { total = cpu_total or 0, idle = cpu_idle or 0 }

  local mem_used, mem_total = parse_linux_memory()
  return {
    cpu = cpu and math.floor(cpu * 10 + 0.5) / 10 or nil,
    mem_used = mem_used,
    mem_total = mem_total,
  }
end

local function collect_macos()
  local script = table.concat({
    "total=$(sysctl -n hw.memsize 2>/dev/null)",
    "vm=$(vm_stat 2>/dev/null)",
    "page_size=$(printf '%s\n' \"$vm\" | awk '/page size of/ {print $8}')",
    "active=$(printf '%s\n' \"$vm\" | awk '/Pages active/ {gsub(\"\\\\.\",\"\",$3); print $3}')",
    "wired=$(printf '%s\n' \"$vm\" | awk '/Pages wired down/ {gsub(\"\\\\.\",\"\",$4); print $4}')",
    "compressed=$(printf '%s\n' \"$vm\" | awk '/Pages occupied by compressor/ {gsub(\"\\\\.\",\"\",$5); print $5}')",
    "used=$(( (active + wired + compressed) * page_size ))",
    "cpu=$(top -l 1 -n 0 | awk -F'[:, ]+' '/CPU usage/ {print 100-$7; exit}')",
    "printf 'CPU=%s\\n' \"$cpu\"",
    "printf 'MEM_USED=%s\\n' \"$used\"",
    "printf 'MEM_TOTAL=%s\\n' \"$total\"",
  }, '; ')

  local stdout = run_child({ '/bin/sh', '-lc', script })
  local parsed = parse_key_value_lines(stdout)
  return {
    cpu = tonumber(parsed.CPU),
    mem_used = tonumber(parsed.MEM_USED),
    mem_total = tonumber(parsed.MEM_TOTAL),
  }
end

function M.sample()
  local now = now_ms()
  if state.cache and (now - state.last_sample_ms) < sample_interval_ms() then
    return state.cache
  end

  local os_name = detect_os()
  local sample
  if os_name == 'windows' then
    sample = collect_windows()
  elseif os_name == 'macos' then
    sample = collect_macos()
  else
    sample = collect_linux()
  end

  state.cache = sample or {}
  state.last_sample_ms = now
  return state.cache
end

function M.cpu_text(sample)
  if sample and sample.cpu ~= nil then
    return string.format('%.1f%%', sample.cpu)
  end
  return nil
end

function M.memory_text(sample)
  if sample and sample.mem_used and sample.mem_total then
    return string.format('%s / %s', human_bytes(sample.mem_used), human_bytes(sample.mem_total))
  end
  return nil
end

return M

