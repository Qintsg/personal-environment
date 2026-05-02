local map = vim.keymap.set
local hints = require("user.hints")
local neovide = require("config.neovide")

map({ "n", "i", "v" }, "<C-s>", function()
  local ok, err = pcall(vim.cmd.write)
  if not ok then
    vim.notify(err, vim.log.levels.WARN, { title = "淇濆瓨澶辫触" })
  end
end, { desc = "淇濆瓨鏂囦欢", silent = true })

map("n", "<C-t>", function()
  vim.cmd("botright 12split | terminal")
  vim.cmd.startinsert()
end, { desc = "鎵撳紑缁堢", silent = true })

map("n", "<leader>ft", function()
  vim.cmd("botright 12split | terminal")
  vim.cmd.startinsert()
end, { desc = "鎵撳紑缁堢", silent = true })

map("t", "<Esc>", [[<C-\><C-n>]], { desc = "缁堢鏅€氭ā寮? })
map("t", "<C-q>", [[<C-\><C-n>:close<CR>]], { desc = "鍏抽棴缁堢" })

map("n", "<A-o>", "o<Esc>", { desc = "涓嬫柟鏂板缓涓€琛? })
map("n", "<A-O>", "O<Esc>", { desc = "涓婃柟鏂板缓涓€琛? })

map("n", "<leader>fn", function()
  vim.cmd("ene")
  vim.cmd("startinsert")
end, { desc = "鏂板缓鏂囦欢" })

map("n", "<leader>fw", function()
  LazyVim.pick("grep_string", { word_match = "-w" })()
end, { desc = "鎼滅储褰撳墠璇? })

map("n", "<leader>uh", function()
  hints.show()
end, { desc = "蹇嵎閿€昏" })

map("n", "<leader>uN", function()
  hints.show("neovide")
end, { desc = "Neovide 蹇嵎閿? })

map({ "n", "i", "v" }, "<C-=>", function()
  neovide.scale(0.1)
end, { desc = "Neovide 鏀惧ぇ" })

map({ "n", "i", "v" }, "<C-->", function()
  neovide.scale(-0.1)
end, { desc = "Neovide 缂╁皬" })

map({ "n", "i", "v" }, "<C-0>", function()
  neovide.reset_scale()
end, { desc = "Neovide 閲嶇疆缂╂斁" })

map({ "n", "i", "v" }, "<F11>", function()
  neovide.toggle_fullscreen()
end, { desc = "Neovide 鍏ㄥ睆" })

