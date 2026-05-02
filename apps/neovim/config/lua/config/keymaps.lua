local map = vim.keymap.set
local hints = require("user.hints")
local neovide = require("config.neovide")

map({ "n", "i", "v" }, "<C-s>", function()
  local ok, err = pcall(vim.cmd.write)
  if not ok then
    vim.notify(err, vim.log.levels.WARN, { title = "保存失败" })
  end
end, { desc = "保存文件", silent = true })

map("n", "<C-t>", function()
  vim.cmd("botright 12split | terminal")
  vim.cmd.startinsert()
end, { desc = "打开终端", silent = true })

map("n", "<leader>ft", function()
  vim.cmd("botright 12split | terminal")
  vim.cmd.startinsert()
end, { desc = "打开终端", silent = true })

map("t", "<Esc>", [[<C-\><C-n>]], { desc = "终端普通模式" })
map("t", "<C-q>", [[<C-\><C-n>:close<CR>]], { desc = "关闭终端" })

map("n", "<A-o>", "o<Esc>", { desc = "下方新建一行" })
map("n", "<A-O>", "O<Esc>", { desc = "上方新建一行" })

map("n", "<leader>fn", function()
  vim.cmd("ene")
  vim.cmd("startinsert")
end, { desc = "新建文件" })

map("n", "<leader>fw", function()
  LazyVim.pick("grep_string", { word_match = "-w" })()
end, { desc = "搜索当前词" })

map("n", "<leader>uh", function()
  hints.show()
end, { desc = "快捷键总览" })

map("n", "<leader>uN", function()
  hints.show("neovide")
end, { desc = "Neovide 快捷键" })

map({ "n", "i", "v" }, "<C-=>", function()
  neovide.scale(0.1)
end, { desc = "Neovide 放大" })

map({ "n", "i", "v" }, "<C-->", function()
  neovide.scale(-0.1)
end, { desc = "Neovide 缩小" })

map({ "n", "i", "v" }, "<C-0>", function()
  neovide.reset_scale()
end, { desc = "Neovide 重置缩放" })

map({ "n", "i", "v" }, "<F11>", function()
  neovide.toggle_fullscreen()
end, { desc = "Neovide 全屏" })

