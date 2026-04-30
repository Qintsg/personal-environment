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
    "f 鏌ユ壘鏂囦欢",
    "r 鏈€杩戞枃浠?,
    "e 鏂囦欢鏍?,
    "g 鍏ㄦ枃鎼滅储",
    "n 鏂板缓鏂囦欢",
    "t 缁堢",
    "k 蹇嵎閿?,
    "q 閫€鍑?,
  }
end

local function lazy_items()
  return {
    "S 鍚屾鎻掍欢",
    "U 鏇存柊鎻掍欢",
    "I 瀹夎鎻掍欢",
    "X 娓呯悊鎻掍欢",
    "? 甯姪",
    "q 鍏抽棴",
  }
end

local function mason_items()
  return {
    "<CR> 鎵撳紑/瀹夎",
    "i 瀹夎",
    "u 鏇存柊",
    "X 鍗歌浇",
    "g? 甯姪",
  }
end

local function code_items(mode)
  if mode:find("i", 1, true) == 1 then
    return {
      "Esc 杩斿洖鏅€氭ā寮?,
      "<C-s> 淇濆瓨",
      "<leader>ca 浠ｇ爜鎿嶄綔",
      "K 鎮仠鏂囨。",
      "gd 璺宠浆瀹氫箟",
    }
  end

  return {
    "<C-s> 淇濆瓨鏂囦欢",
    "<leader>ff 鏂囦欢鎼滅储",
    "<leader>fr 鏈€杩戞枃浠?,
    "<leader>sg 鍏ㄦ枃鎼滅储",
    "<leader>e 鏂囦欢鏍?,
    "<leader>bd 鍏抽棴缂撳啿鍖?,
    "<leader>fm 鏍煎紡鍖?,
    "<leader>qq 閫€鍑?,
  }
end

local function neovide_items()
  return {
    "<C-=> 鏀惧ぇ",
    "<C--> 缂╁皬",
    "<C-0> 閲嶇疆缂╂斁",
    "<F11> 鍏ㄥ睆",
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
  local neovide_ready = vim.g.neovide and "宸茶繛鎺? or "鍚姩 Neovide 鍚庣敓鏁?
  return {
    "Qintsg 蹇嵎閿€昏",
    "",
    "鏈€甯哥敤",
    "  <C-s>        淇濆瓨褰撳墠鏂囦欢",
    "  <leader>ff   鏌ユ壘鏂囦欢",
    "  <leader>fr   鎵撳紑鏈€杩戞枃浠?,
    "  <leader>e    鍒囨崲鏂囦欢鏍?,
    "  <leader>bd   鍏抽棴褰撳墠缂撳啿鍖?,
    "  <leader>qq   閫€鍑?Neovim",
    "",
    "鎼滅储涓庤烦杞?,
    "  <leader>sg   鍏ㄦ枃鎼滅储",
    "  <leader>,    鍒囨崲缂撳啿鍖?,
    "  gd           璺宠浆瀹氫箟",
    "  gr           鏌ユ壘寮曠敤",
    "  K            鎮仠鏂囨。",
    "",
    "浠ｇ爜鎿嶄綔",
    "  <leader>ca   浠ｇ爜鎿嶄綔",
    "  <leader>cr   閲嶅懡鍚嶇鍙?,
    "  <leader>fm   鏍煎紡鍖栧綋鍓嶇紦鍐插尯",
    "  gcc          娉ㄩ噴褰撳墠琛?,
    "  <C-t>        鎵撳紑缁堢",
    "",
    "绯荤粺涓庣晫闈?,
    "  <leader>l    鎵撳紑 Lazy 鎻掍欢绠＄悊鍣?,
    "  <leader>cm   鎵撳紑 Mason 宸ュ叿绠＄悊鍣?,
    "  <leader>uh   鎵撳紑鎬诲揩鎹烽敭闈㈡澘",
    "  <leader>uN   鎵撳紑 Neovide 蹇嵎閿?,
    "",
    "Neovide锛? .. neovide_ready .. "锛?,
    "  <C-=>        鏀惧ぇ鐣岄潰",
    "  <C-->        缂╁皬鐣岄潰",
    "  <C-0>        閲嶇疆缂╂斁",
    "  <F11>        鍒囨崲鍏ㄥ睆",
  }
end

local function neovide_lines()
  return {
    "Neovide 蹇嵎閿?,
    "",
    "甯哥敤",
    "  <leader>uh   鎵撳紑鎬诲揩鎹烽敭闈㈡澘",
    "  <leader>uN   浠呮煡鐪?Neovide 蹇嵎閿?,
    "",
    "缂╂斁涓庣獥鍙?,
    "  <C-=>        鏀惧ぇ鐣岄潰",
    "  <C-->        缂╁皬鐣岄潰",
    "  <C-0>        閲嶇疆缂╂斁",
    "  <F11>        鍒囨崲鍏ㄥ睆",
    "",
    "褰撳墠浣撻獙",
    "  閫忔槑搴?       0.96",
    "  鍏夋爣鐗规晥      pixiedust",
    "  鍒锋柊鐜?       120Hz",
    "  鍦嗚闃村奖      宸插惎鐢?,
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
    title = " 蹇嵎閿彁绀?",
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

