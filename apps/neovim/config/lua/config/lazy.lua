local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { vim.fn.has("nvim-0.12") == 1 and "" or "\nNeovim 0.12+ is recommended for this config." },
    }, true, {})
    if #vim.api.nvim_list_uis() > 0 then
      vim.fn.getchar()
    end
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local function prepend_path(path)
  if not path or path == "" or vim.fn.isdirectory(path) == 0 then
    return
  end

  local path_env = vim.env.PATH or ""
  if not (":" .. path_env .. ":"):find(":" .. path .. ":", 1, true) then
    vim.env.PATH = path .. ":" .. path_env
  end
end

if vim.fn.has("unix") == 1 then
  local node = vim.fn.exepath("node")
  local node_realpath = node ~= "" and (vim.uv or vim.loop).fs_realpath(node) or nil
  if node_realpath and node_realpath:find("/.nvm/versions/node/", 1, true) then
    prepend_path(vim.fn.fnamemodify(node_realpath, ":h"))
  end
end

vim.g.lazyvim_picker = "telescope"

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazy_plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  git = {
    timeout = 600,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = false,
    notify = false,
  },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "matchit",
        "matchparen",
      },
    },
  },
})

