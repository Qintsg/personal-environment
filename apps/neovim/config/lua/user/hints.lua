local M = {}

local function join(items)
  local parts = {}
  local sep = "  |  "
  local limit = math.max(vim.o.columns - 24, 72)

  for _, item in ipairs(items) do
    local candidate = (#parts == 0) and item or (table.concat(parts, sep) .. sep .. item)
    if vim.fn.strdisplaywidth(candidate) > limit then
      break
    end
    parts[#parts + 1] = item
  end

  return table.concat(parts, sep)
end

local function dashboard_items()
  return {
    "f 查找文件",
    "r 最近文件",
    "e 文件树",
    "g 全文搜索",
    "n 新建文件",
    "t 终端",
    "k 快捷键",
    "q 退出",
  }
end

local function lazy_items()
  return {
    "S 同步插件",
    "U 更新插件",
    "I 安装插件",
    "X 清理插件",
    "? 帮助",
    "q 关闭",
  }
end

local function mason_items()
  return {
    "<CR> 打开/安装",
    "i 安装",
    "u 更新",
    "X 卸载",
    "g? 帮助",
  }
end

local function code_items(mode)
  if mode:find("i", 1, true) == 1 then
    return {
      "Esc 返回普通模式",
      "<C-s> 保存",
      "<leader>ca 代码操作",
      "K 悬停文档",
      "gd 跳转定义",
    }
  end

  return {
    "<C-s> 保存文件",
    "<leader>ff 文件搜索",
    "<leader>fr 最近文件",
    "<leader>sg 全文搜索",
    "<leader>e 文件树",
    "<leader>bd 关闭缓冲区",
    "<leader>fm 格式化",
    "<leader>qq 退出",
  }
end

local function neovide_items()
  return {
    "<C-=> 放大",
    "<C--> 缩小",
    "<C-0> 重置缩放",
    "<F11> 全屏",
    "<leader>uN Neovide",
  }
end

function M.statusline()
  local ft = vim.bo.filetype
  local mode = vim.api.nvim_get_mode().mode

  if ft == "dashboard" then
    return join(dashboard_items())
  elseif ft == "lazy" then
    return join(lazy_items())
  elseif ft == "mason" then
    return join(mason_items())
  elseif vim.g.neovide then
    return join(neovide_items())
  else
    return join(code_items(mode))
  end
end

function M.color()
  local ft = vim.bo.filetype
  if ft == "dashboard" then
    return { fg = "#ffffff", bg = "#986801" }
  elseif ft == "lazy" or ft == "mason" then
    return { fg = "#383a42", bg = "#f0f2f5" }
  end
  return { fg = "#383a42", bg = "#f0f2f5" }
end

local function all_lines()
  local neovide_ready = vim.g.neovide and "已连接" or "启动 Neovide 后生效"
  return {
    "Qintsg 快捷键总览",
    "",
    "最常用",
    "  <C-s>        保存当前文件",
    "  <leader>ff   查找文件",
    "  <leader>fr   打开最近文件",
    "  <leader>e    切换文件树",
    "  <leader>bd   关闭当前缓冲区",
    "  <leader>qq   退出 Neovim",
    "",
    "搜索与跳转",
    "  <leader>sg   全文搜索",
    "  <leader>,    切换缓冲区",
    "  gd           跳转定义",
    "  gr           查找引用",
    "  K            悬停文档",
    "",
    "代码操作",
    "  <leader>ca   代码操作",
    "  <leader>cr   重命名符号",
    "  <leader>fm   格式化当前缓冲区",
    "  gcc          注释当前行",
    "  <C-t>        打开终端",
    "",
    "系统与界面",
    "  <leader>l    打开 Lazy 插件管理器",
    "  <leader>cm   打开 Mason 工具管理器",
    "  <leader>uh   打开总快捷键面板",
    "  <leader>uN   打开 Neovide 快捷键",
    "",
    "Neovide（" .. neovide_ready .. "）",
    "  <C-=>        放大界面",
    "  <C-->        缩小界面",
    "  <C-0>        重置缩放",
    "  <F11>        切换全屏",
  }
end

local function neovide_lines()
  return {
    "Neovide 快捷键",
    "",
    "常用",
    "  <leader>uh   打开总快捷键面板",
    "  <leader>uN   仅查看 Neovide 快捷键",
    "",
    "缩放与窗口",
    "  <C-=>        放大界面",
    "  <C-->        缩小界面",
    "  <C-0>        重置缩放",
    "  <F11>        切换全屏",
    "",
    "当前体验",
    "  透明度        0.96",
    "  光标特效      pixiedust",
    "  刷新率        120Hz",
    "  圆角阴影      已启用",
  }
end

local function build_lines(section)
  if section == "neovide" then
    return neovide_lines()
  end
  return all_lines()
end

function M.show(section)
  local lines = build_lines(section)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "lazyvim-hints"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width + 6,
    height = #lines + 2,
    row = math.max(1, math.floor((vim.o.lines - (#lines + 2)) / 2) - 1),
    col = math.max(1, math.floor((vim.o.columns - (width + 6)) / 2)),
    style = "minimal",
    border = "rounded",
    title = " 快捷键提示 ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true })
end

return M

