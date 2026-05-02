pcall(vim.cmd, "language zh_CN.UTF-8")

vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_ts_lsp = "vtsls"
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.filetype.add({
  extension = {
    c = "c",
    cc = "cpp",
    cjs = "javascript",
    cpp = "cpp",
    css = "css",
    cts = "typescript",
    cxx = "cpp",
    dart = "dart",
    h = "c",
    hpp = "cpp",
    hxx = "cpp",
    html = "html",
    java = "java",
    js = "javascript",
    json = "json",
    jsonc = "jsonc",
    jsx = "javascriptreact",
    lua = "lua",
    md = "markdown",
    mjs = "javascript",
    mts = "typescript",
    nu = "nu",
    py = "python",
    rs = "rust",
    sql = "sql",
    toml = "toml",
    ts = "typescript",
    tsx = "typescriptreact",
    vue = "vue",
    yaml = "yaml",
    yml = "yaml",
  },
  filename = {
    [".npmrc"] = "dosini",
    [".nvmrc"] = "text",
    ["package.json"] = "json",
    ["package-lock.json"] = "json",
    ["vite.config.js"] = "javascript",
    ["vite.config.mjs"] = "javascript",
    ["vite.config.ts"] = "typescript",
  },
})

local opt = vim.opt
local undo_dir = vim.fn.stdpath("state") .. "/undo"

vim.fn.mkdir(undo_dir, "p")

opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.timeoutlen = 450
opt.ttimeoutlen = 10
opt.updatetime = 200
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 12
opt.colorcolumn = "100"
opt.numberwidth = 3
opt.signcolumn = "yes:1"
opt.showtabline = 0
opt.laststatus = 3
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = false
opt.undofile = true
opt.undodir = undo_dir
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.splitbelow = true
opt.splitright = true
opt.ignorecase = true
opt.smartcase = true
opt.infercase = true
opt.inccommand = "split"
opt.virtualedit = "block"
opt.jumpoptions = "view"
opt.list = true
opt.listchars = { tab = "  ", trail = "路", extends = "禄", precedes = "芦", nbsp = "鈵? }
opt.fillchars = { eob = " ", fold = " ", foldopen = "飸?, foldsep = " ", foldclose = "飸? }
opt.diffopt:append({ "algorithm:histogram", "indent-heuristic", "linematch:60" })
opt.shortmess:append("cC")
opt.sessionoptions:remove("options")

if not vim.env.SSH_TTY then
  opt.clipboard = "unnamedplus"
end

if vim.fn.exists("&winborder") == 1 then
  opt.winborder = "rounded"
end

if vim.fn.exists("&smoothscroll") == 1 then
  opt.smoothscroll = true
end

if vim.fn.has("win32") == 1 then
  opt.shellslash = true
end

require("config.neovide")

