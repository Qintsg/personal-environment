local wezterm = require 'wezterm'

local M = {}

local prompt_shown = false

local font_packs = {
  {
    id = 'maple',
    family = 'Maple Mono NF CN',
    marker = '.maple.ok',
    windows = {
      owner = 'subframe7536',
      repo = 'maple-font',
      asset_like = 'MapleMono-NF-CN-unhinted.zip',
    },
    unix = {
      owner = 'subframe7536',
      repo = 'maple-font',
      asset_glob = 'MapleMono-NF-CN-unhinted.zip',
    },
  },
  {
    id = 'cascadia',
    family = 'Cascadia Mono',
    marker = '.cascadia.ok',
    windows = {
      owner = 'microsoft',
      repo = 'cascadia-code',
      asset_like = 'CascadiaCode-*.zip',
    },
    unix = {
      owner = 'microsoft',
      repo = 'cascadia-code',
      asset_glob = 'CascadiaCode-*.zip',
    },
  },
  {
    id = 'jetbrains',
    family = 'JetBrains Mono',
    marker = '.jetbrains.ok',
    windows = {
      owner = 'JetBrains',
      repo = 'JetBrainsMono',
      asset_like = 'JetBrainsMono-*.zip',
    },
    unix = {
      owner = 'JetBrains',
      repo = 'JetBrainsMono',
      asset_glob = 'JetBrainsMono-*.zip',
    },
  },
  {
    id = 'nerd-symbols',
    family = 'Symbols Nerd Font Mono',
    marker = '.symbols-nerd.ok',
    windows = {
      owner = 'ryanoasis',
      repo = 'nerd-fonts',
      asset_like = 'NerdFontsSymbolsOnly.zip',
    },
    unix = {
      owner = 'ryanoasis',
      repo = 'nerd-fonts',
      asset_glob = 'NerdFontsSymbolsOnly.zip',
    },
  },
}

local function is_windows()
  local triple = tostring(wezterm.target_triple or ''):lower()
  return package.config:sub(1, 1) == '\\' or triple:find('windows', 1, true) ~= nil
end

local function font_root()
  return wezterm.config_dir .. '/fonts'
end

local function marker_path(pack)
  return font_root() .. '/' .. pack.marker
end

local function file_exists(path)
  local handle = io.open(path, 'rb')
  if handle then
    handle:close()
    return true
  end
  return false
end

local function ensure_dir(path)
  if is_windows() then
    wezterm.run_child_process({
      'powershell.exe',
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-WindowStyle',
      'Hidden',
      '-Command',
      "New-Item -ItemType Directory -Force -Path '" .. path:gsub("'", "''") .. "' | Out-Null",
    })
  else
    wezterm.run_child_process({ '/bin/sh', '-lc', "mkdir -p '" .. path:gsub("'", "'\\''") .. "'" })
  end
end

local function installed(pack)
  return file_exists(marker_path(pack))
end

function M.available_families()
  ensure_dir(font_root())

  local families = {
    'JetBrainsMono Nerd Font',
    'JetBrainsMono Nerd Font Mono',
  }
  for _, pack in ipairs(font_packs) do
    if installed(pack) then
      local exists = false
      for _, family in ipairs(families) do
        if family == pack.family then
          exists = true
          break
        end
      end
      if not exists then
        table.insert(families, pack.family)
      end
    end
  end

  -- 鍗充娇灏氭湭瀹夎鎺ㄨ崘瀛椾綋锛屼篃淇濊瘉浣跨敤 WezTerm 鍐呯疆鍙敤瀛椾綋锛屼笉瑙﹀彂缂哄瓧浣撹鍛娿€?  if #families == 0 then
    table.insert(families, 'JetBrains Mono')
  end
  table.insert(families, 'Symbols Nerd Font Mono')

  return families
end

local function missing_packs()
  local missing = {}
  for _, pack in ipairs(font_packs) do
    if not installed(pack) then
      table.insert(missing, pack)
    end
  end
  return missing
end

local function build_windows_installer_command(packs)
  local pack_items = {}
  for _, pack in ipairs(packs) do
    local spec = pack.windows
    table.insert(pack_items, string.format(
      "@{ family='%s'; marker='%s'; owner='%s'; repo='%s'; asset='%s' }",
      pack.family,
      marker_path(pack):gsub("'", "''"),
      spec.owner,
      spec.repo,
      spec.asset_like
    ))
  end

  local script = [[
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$fontRoot = ']] .. font_root():gsub("'", "''") .. [['
New-Item -ItemType Directory -Force -Path $fontRoot | Out-Null
$packs = @(
]] .. table.concat(pack_items, ",\n") .. [[
)

Write-Host ''
Write-Host '========================================='
Write-Host ' WezTerm 瀛椾綋瀹夎'
Write-Host '========================================='
Write-Host "瀹夎鐩綍: $fontRoot"
Write-Host ''

$total = $packs.Count
$index = 0
foreach ($pack in $packs) {
  $index++
  Write-Host ("[{0}/{1}] 澶勭悊 {2}" -f $index, $total, $pack.family) -ForegroundColor Cyan
  $release = Invoke-RestMethod -Uri ("https://api.github.com/repos/{0}/{1}/releases/latest" -f $pack.owner, $pack.repo) -Headers @{ 'User-Agent' = 'wezterm-font-bootstrap' }
  $asset = $release.assets | Where-Object { $_.name -like $pack.asset } | Select-Object -First 1
  if (-not $asset) {
    throw "鎵句笉鍒板瓧浣撹祫婧愶細$($pack.family)"
  }

  $tmp = Join-Path $env:TEMP ("wezterm-font-" + [guid]::NewGuid().ToString())
  $zip = Join-Path $tmp "font.zip"
  $extract = Join-Path $tmp "extract"
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  New-Item -ItemType Directory -Force -Path $extract | Out-Null

  Write-Host ("  涓嬭浇: {0}" -f $asset.name)
  & curl.exe -L --progress-bar $asset.browser_download_url -o $zip
  if ($LASTEXITCODE -ne 0) { throw "涓嬭浇澶辫触锛?($pack.family)" }

  Write-Host "  瑙ｅ帇涓?.."
  Expand-Archive -Path $zip -DestinationPath $extract -Force

  Write-Host "  澶嶅埗瀛椾綋鏂囦欢..."
  Get-ChildItem -Path $extract -Recurse -Include *.ttf,*.otf | ForEach-Object {
    Copy-Item $_.FullName -Destination $fontRoot -Force
  }

  Set-Content -Path $pack.marker -Value $release.tag_name -Encoding UTF8
  Remove-Item -Path $tmp -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host ("  瀹屾垚: {0}" -f $pack.family) -ForegroundColor Green
  Write-Host ''
}

Write-Host '鍏ㄩ儴瀛椾綋瀹夎瀹屾垚銆? -ForegroundColor Green
Write-Host '璇疯繑鍥?WezTerm 鍚庢寜 Ctrl+Shift+R 閲嶈浇閰嶇疆銆?
Write-Host ''
Read-Host '鎸夊洖杞﹀叧闂鏍囩椤?
]]

  return {
    'powershell.exe',
    '-NoLogo',
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    script,
  }
end

local function build_unix_installer_command(packs)
  local pack_items = {}
  for _, pack in ipairs(packs) do
    local spec = pack.unix
    table.insert(pack_items, string.format(
      "{'family': %q, 'marker': %q, 'owner': %q, 'repo': %q, 'asset_glob': %q}",
      pack.family,
      marker_path(pack),
      spec.owner,
      spec.repo,
      spec.asset_glob
    ))
  end

  local script = [[
import fnmatch
import json
import os
import shutil
import sys
import tempfile
import urllib.request
import zipfile

font_root = ]] .. string.format('%q', font_root()) .. [[
packs = ]] .. "[" .. table.concat(pack_items, ", ") .. "]" .. [[
os.makedirs(font_root, exist_ok=True)

print("")
print("=========================================")
print(" WezTerm 瀛椾綋瀹夎")
print("=========================================")
print("瀹夎鐩綍:", font_root)
print("")

for index, pack in enumerate(packs, start=1):
    print(f"[{index}/{len(packs)}] 澶勭悊 {pack['family']}")
    req = urllib.request.Request(
        f"https://api.github.com/repos/{pack['owner']}/{pack['repo']}/releases/latest",
        headers={'User-Agent': 'wezterm-font-bootstrap'}
    )
    with urllib.request.urlopen(req) as resp:
        release = json.load(resp)

    asset = None
    for item in release.get('assets', []):
        if fnmatch.fnmatch(item.get('name', ''), pack['asset_glob']):
            asset = item
            break
    if asset is None:
        raise RuntimeError(f"鎵句笉鍒板瓧浣撹祫婧愶細{pack['family']}")

    print(f"  涓嬭浇: {asset['name']}")
    with tempfile.TemporaryDirectory(prefix='wezterm-font-') as tmp:
        zip_path = os.path.join(tmp, 'font.zip')
        extract_dir = os.path.join(tmp, 'extract')
        os.makedirs(extract_dir, exist_ok=True)
        with urllib.request.urlopen(asset['browser_download_url']) as resp, open(zip_path, 'wb') as out:
            total = int(resp.headers.get('Content-Length', '0'))
            downloaded = 0
            last_percent = -1
            while True:
                chunk = resp.read(1024 * 256)
                if not chunk:
                    break
                out.write(chunk)
                downloaded += len(chunk)
                if total > 0:
                    percent = int(downloaded * 100 / total)
                    if percent != last_percent:
                        bar = '#' * (percent // 4) + '-' * (25 - percent // 4)
                        sys.stdout.write(f"\r  [{bar}] {percent:3d}%")
                        sys.stdout.flush()
                        last_percent = percent
            if total > 0:
                sys.stdout.write("\n")
                sys.stdout.flush()

        print("  瑙ｅ帇涓?..")
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(extract_dir)

        print("  澶嶅埗瀛椾綋鏂囦欢...")
        for root, _, files in os.walk(extract_dir):
            for name in files:
                if name.lower().endswith(('.ttf', '.otf')):
                    shutil.copy2(os.path.join(root, name), os.path.join(font_root, name))

    with open(pack['marker'], 'w', encoding='utf-8') as fp:
        fp.write(release.get('tag_name', 'installed'))

    print(f"  瀹屾垚: {pack['family']}")
    print("")

print("鍏ㄩ儴瀛椾綋瀹夎瀹屾垚銆?)
print("璇烽噸鍚疻ezTerm閲嶈浇閰嶇疆銆?)
input("鎸夊洖杞﹀叧闂鏍囩椤?)
]]

  return {
    '/bin/sh',
    '-lc',
    "python3 -c " .. string.format('%q', script) ..
    " 2>/dev/null || python -c " .. string.format('%q', script),
  }
end

function M.register_prompt(wezterm)
  wezterm.on('update-status', function(window, pane)
    if prompt_shown then
      return
    end

    local packs = missing_packs()
    if #packs == 0 then
      return
    end

    prompt_shown = true
    local names = {}
    for _, pack in ipairs(packs) do
      table.insert(names, pack.family)
    end

    window:perform_action(
      wezterm.action.InputSelector({
        title = '妫€娴嬪埌缂哄皯鎺ㄨ崘瀛椾綋',
        choices = {
          {
            id = 'install',
            label = '鎵撳紑瀛椾綋瀹夎椤甸潰骞跺紑濮嬩笅杞?,
          },
          {
            id = 'skip',
            label = '鏈璺宠繃',
          },
        },
        action = wezterm.action_callback(function(inner_window, inner_pane, id)
          if id ~= 'install' then
            inner_window:toast_notification('WezTerm 瀛椾綋', '宸茶烦杩囧瓧浣撳畨瑁?, nil, 3000)
            return
          end

          local args
          if is_windows() then
            args = build_windows_installer_command(packs)
          else
            args = build_unix_installer_command(packs)
          end

          inner_window:toast_notification(
            'WezTerm 瀛椾綋',
            '鍗冲皢鎵撳紑瀛椾綋瀹夎鏍囩椤碉細' .. table.concat(names, '銆?),
            nil,
            4000
          )
          inner_window:perform_action(
            wezterm.action.SpawnCommandInNewTab({
              args = args,
              cwd = wezterm.home_dir,
            }),
            inner_pane
          )
        end),
      }),
      pane
    )
  end)
end

return M

