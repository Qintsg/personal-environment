local lib = require "custom.lib"
local zh = lib.zh
local update_key_desc = lib.update_key_desc

Ice.plugins.bufferline.opts.options.offsets[1].text = zh(25991, 20214, 26641)

update_key_desc("bufferline", "<leader>bc", zh(36873, 25321, 24182, 20851, 38381))
update_key_desc("bufferline", "<leader>bd", zh(20851, 38381, 24403, 21069, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bh", zh(19978, 19968, 20010, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bl", zh(19979, 19968, 20010, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bo", zh(20851, 38381, 20854, 20182, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bp", zh(36873, 25321, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bm", zh(21491, 31227, 32531, 20914, 21306))
update_key_desc("bufferline", "<leader>bM", zh(24038, 31227, 32531, 20914, 21306))

update_key_desc("nvim-tree", "<leader>uf", zh(20999, 25442, 25991, 20214, 26641))
update_key_desc("telescope", "<leader>tf", zh(25628, 32034, 25991, 20214))
update_key_desc("telescope", "<leader>t<C-f>", zh(20840, 25991, 25628, 32034))
update_key_desc("telescope", "<leader>uc", zh(26597, 30475, 37197, 32622))
update_key_desc("todo-comments", "<leader>ut", "TODO " .. zh(21015, 34920))
update_key_desc("null-ls", "<leader>lf", zh(26684, 24335, 21270, 20195, 30721))
update_key_desc("avante", "<leader>aa", "Avante " .. zh(25552, 38382))
update_key_desc("avante", "<leader>at", "Avante " .. zh(20999, 25442))
update_key_desc("avante", "<leader>awc", zh(32858, 28966, 36873, 20013, 20195, 30721))
update_key_desc("avante", "<leader>awi", zh(32858, 28966, 36755, 20837, 26694))
update_key_desc("avante", "<leader>awa", zh(32858, 28966, 32467, 26524, 31383))
update_key_desc("avante", "<leader>aws", zh(32858, 28966, 24050, 36873, 25991, 20214))
update_key_desc("avante", "<leader>awt", zh(32858, 28966, 24453, 21150))

update_key_desc("gitsigns", "<leader>gn", zh(19979, 19968, 20010, 21464, 26356))
update_key_desc("gitsigns", "<leader>gp", zh(19978, 19968, 20010, 21464, 26356))
update_key_desc("gitsigns", "<leader>gP", zh(39044, 35272, 21464, 26356))
update_key_desc("gitsigns", "<leader>gs", zh(26242, 23384, 21464, 26356))
update_key_desc("gitsigns", "<leader>gu", zh(25764, 38144, 26242, 23384))
update_key_desc("gitsigns", "<leader>gr", zh(37325, 32622, 21464, 26356))
update_key_desc("gitsigns", "<leader>gB", zh(26242, 23384, 25972, 20010, 32531, 20914, 21306))
update_key_desc("gitsigns", "<leader>gb", "Git Blame")
update_key_desc("gitsigns", "<leader>gl", zh(24403, 21069, 34892, 32) .. "Git Blame")

update_key_desc("grug-far", "<leader>ug", zh(26597, 25214, 19982, 26367, 25442))
update_key_desc("hop", "<leader>hp", zh(24555, 36895, 21333, 35789))
update_key_desc("markdown-preview", "<A-b>", "Markdown " .. zh(39044, 35272))
update_key_desc("neogit", "<leader>gt", "Neogit")

update_key_desc("ufo", "zR", zh(23637, 24320, 25152, 26377, 25240, 21472))
update_key_desc("ufo", "zM", zh(20851, 38381, 25152, 26377, 25240, 21472))
update_key_desc("ufo", "zp", zh(39044, 35272, 25240, 21472, 20869, 23481))

update_key_desc("lspsaga", "<leader>lr", zh(37325, 21629, 21517, 31216))
update_key_desc("lspsaga", "<leader>lc", zh(20195, 30721, 25805, 20316))
update_key_desc("lspsaga", "<leader>ld", zh(36339, 36716, 21040, 23450, 20041))
update_key_desc("lspsaga", "<leader>lD", zh(39044, 35272, 23450, 20041))
update_key_desc("lspsaga", "K", zh(24748, 20572, 25991, 26723))
update_key_desc("lspsaga", "<leader>lR", zh(24341, 29992))
update_key_desc("lspsaga", "<leader>li", zh(36339, 36716, 21040, 23454, 29616))
update_key_desc("lspsaga", "<leader>lP", zh(26174, 31034, 34892, 35786, 26029))
update_key_desc("lspsaga", "<leader>ln", zh(19979, 19968, 20010, 35786, 26029))
update_key_desc("lspsaga", "<leader>lp", zh(19978, 19968, 20010, 35786, 26029))

update_key_desc("trouble", "<leader>lt", "Trouble " .. zh(20999, 25442))
update_key_desc("typst-preview", "<A-b>", "Typst " .. zh(39044, 35272, 20999, 25442))

for _, spec in ipairs(Ice.plugins["which-key"].opts.spec) do
    local mapping = {
        ["<leader>a"] = "+AI",
        ["<leader>b"] = "+" .. zh(32531, 20914, 21306),
        ["<leader>c"] = "+" .. zh(27880, 37322),
        ["<leader>g"] = "+Git",
        ["<leader>h"] = "+" .. zh(36339, 36716),
        ["<leader>l"] = "+LSP",
        ["<leader>t"] = "+" .. zh(25628, 32034),
        ["<leader>u"] = "+" .. zh(24037, 20855),
    }
    if mapping[spec[1]] then
        spec.group = mapping[spec[1]]
    end
end
