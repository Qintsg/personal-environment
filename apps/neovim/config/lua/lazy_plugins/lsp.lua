local function extend_unique(dst, items)
  local seen = {}
  for _, item in ipairs(dst) do
    seen[item] = true
  end
  for _, item in ipairs(items) do
    if not seen[item] then
      dst[#dst + 1] = item
      seen[item] = true
    end
  end
end

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      extend_unique(opts.ensure_installed, {
        "bash-language-server",
        "clang-format",
        "clangd",
        "codelldb",
        "css-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-language-server",
        "eslint-lsp",
        "eslint_d",
        "gopls",
        "html-lsp",
        "java-debug-adapter",
        "java-test",
        "jdtls",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "prettier",
        "prettierd",
        "pyright",
        "ruff",
        "rust-analyzer",
        "shfmt",
        "sqlfluff",
        "stylua",
        "taplo",
        "tailwindcss-language-server",
        "tinymist",
        "typescript-language-server",
        "vtsls",
        "vue-language-server",
        "yaml-language-server",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      extend_unique(opts.ensure_installed, {
        "bash",
        "c",
        "cpp",
        "css",
        "dart",
        "dockerfile",
        "go",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nu",
        "python",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "typst",
        "vue",
        "yaml",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.bashls = opts.servers.bashls or {}
      opts.servers.clangd = opts.servers.clangd or {}
      opts.servers.cssls = opts.servers.cssls or {}
      opts.servers.dockerls = opts.servers.dockerls or {}
      opts.servers.docker_compose_language_service = opts.servers.docker_compose_language_service or {}
      opts.servers.eslint = opts.servers.eslint or {}
      opts.servers.gopls = opts.servers.gopls or {}
      opts.servers.html = opts.servers.html or {}
      opts.servers.jsonls = opts.servers.jsonls or {}
      opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })
      opts.servers.marksman = opts.servers.marksman or {}
      opts.servers.nushell = opts.servers.nushell or {}
      opts.servers.pyright = opts.servers.pyright or {}
      opts.servers.ruff = opts.servers.ruff or {}
      opts.servers.sqlls = opts.servers.sqlls or {}
      opts.servers.taplo = opts.servers.taplo or {}
      opts.servers.tailwindcss = vim.tbl_deep_extend("force", opts.servers.tailwindcss or {}, {
        filetypes_include = { "vue", "typescriptreact", "javascriptreact", "html", "css" },
      })
      opts.servers.tinymist = opts.servers.tinymist or {}
      opts.servers.yamlls = opts.servers.yamlls or {}
      opts.servers.emmet_language_server = vim.tbl_deep_extend("force", opts.servers.emmet_language_server or {}, {
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "pug",
          "typescriptreact",
          "vue",
        },
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.sh = { "shfmt" }
      opts.formatters_by_ft.bash = { "shfmt" }
      opts.formatters_by_ft.c = { "clang_format" }
      opts.formatters_by_ft.cpp = { "clang_format" }
      opts.formatters_by_ft.css = { "prettierd", "prettier" }
      opts.formatters_by_ft.dart = { "dart_format" }
      opts.formatters_by_ft.html = { "prettierd", "prettier" }
      opts.formatters_by_ft.javascript = { "prettierd", "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettierd", "prettier" }
      opts.formatters_by_ft.json = { "prettierd", "prettier" }
      opts.formatters_by_ft.jsonc = { "prettierd", "prettier" }
      opts.formatters_by_ft.markdown = { "prettierd", "prettier" }
      if vim.fn.executable("nufmt") == 1 then
        opts.formatters_by_ft.nu = { "nufmt" }
      end
      opts.formatters_by_ft.python = { "ruff_format" }
      opts.formatters_by_ft.sql = { "sqlfluff" }
      opts.formatters_by_ft.typescript = { "prettierd", "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettierd", "prettier" }
      opts.formatters_by_ft.toml = { "taplo" }
      opts.formatters_by_ft.vue = { "prettierd", "prettier" }
      opts.formatters_by_ft.yaml = { "prettierd", "prettier" }

      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = vim.tbl_deep_extend("force", opts.formatters.sqlfluff or {}, {
        args = { "format", "--dialect=ansi", "-" },
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.javascript = { "eslint_d" }
      opts.linters_by_ft.javascriptreact = { "eslint_d" }
      opts.linters_by_ft.typescript = { "eslint_d" }
      opts.linters_by_ft.typescriptreact = { "eslint_d" }
      opts.linters_by_ft.vue = { "eslint_d" }
      opts.linters_by_ft.sql = { "sqlfluff" }
    end,
  },
}

