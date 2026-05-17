local lib = require "custom.lib"

for _, server in ipairs {
    "bash-language-server",
    "clangd",
    "css-lsp",
    "emmet-ls",
    "flutter",
    "gopls",
    "html-lsp",
    "json-lsp",
    "lua-language-server",
    "omnisharp",
    "pyright",
    "rust",
    "tinymist",
    "typescript-language-server",
} do
    lib.enable(server)
end

Ice.lsp["vue-language-server"] = vim.tbl_deep_extend("force", Ice.lsp["vue-language-server"] or {}, {
    enabled = true,
    formatter = "prettier",
    setup = {
        filetypes = { "vue" },
    },
})

Ice.lsp["yaml-language-server"] = vim.tbl_deep_extend("force", Ice.lsp["yaml-language-server"] or {}, {
    enabled = true,
    formatter = "prettier",
})

Ice.lsp["dockerfile-language-server"] = vim.tbl_deep_extend("force", Ice.lsp["dockerfile-language-server"] or {}, {
    enabled = true,
})

Ice.lsp.marksman = vim.tbl_deep_extend("force", Ice.lsp.marksman or {}, {
    enabled = true,
    formatter = "prettier",
})

Ice.lsp.taplo = vim.tbl_deep_extend("force", Ice.lsp.taplo or {}, {
    enabled = true,
})

lib.extend_unique(Ice.lsp["emmet-ls"].setup.filetypes, { "vue" })
lib.extend_unique(Ice.plugins["nvim-treesitter"].opts.ensure_installed, { "dockerfile", "vue", "yaml" })
