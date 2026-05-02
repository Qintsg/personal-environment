return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      widget_guides = { enabled = true },
      closing_tags = {
        enabled = true,
        prefix = "// ",
      },
      decorations = {
        statusline = {
          app_version = true,
          device = true,
          project_config = true,
        },
      },
      dev_log = { enabled = true, open_cmd = "botright 12split" },
      outline = { open_cmd = "30vnew" },
      lsp = {
        color = {
          enabled = true,
          background = false,
          foreground = false,
          virtual_text = true,
          virtual_text_str = "■",
        },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          enableSnippets = true,
          updateImportsOnRename = true,
          lineLength = 120,
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.dartls = opts.servers.dartls or {}
      opts.servers.dartls.enabled = false
    end,
  },

  {
    "vuki656/package-info.nvim",
    event = { "BufReadPost package.json", "BufNewFile package.json" },
    opts = {
      autostart = true,
      hide_up_to_date = false,
      hide_unstable_versions = false,
      package_manager = "npm",
    },
    keys = {
      { "<leader>ns", "<cmd>PackageInfoShow<cr>", desc = "显示 npm 依赖版本" },
      { "<leader>nh", "<cmd>PackageInfoHide<cr>", desc = "隐藏 npm 依赖版本" },
      { "<leader>nt", "<cmd>PackageInfoToggle<cr>", desc = "切换 npm 依赖版本" },
      { "<leader>nu", "<cmd>PackageInfoUpdate<cr>", desc = "更新 npm 依赖" },
      { "<leader>nd", "<cmd>PackageInfoDelete<cr>", desc = "删除 npm 依赖" },
      { "<leader>ni", "<cmd>PackageInfoInstall<cr>", desc = "安装 npm 依赖" },
    },
  },

  {
    "nvim-mini/mini.icons",
    opts = {
      file = {
        [".npmrc"] = { glyph = "", hl = "MiniIconsRed" },
        [".nvmrc"] = { glyph = "", hl = "MiniIconsGreen" },
        ["package-lock.json"] = { glyph = "", hl = "MiniIconsRed" },
        ["vite.config.js"] = { glyph = "", hl = "MiniIconsYellow" },
        ["vite.config.mjs"] = { glyph = "", hl = "MiniIconsYellow" },
        ["vite.config.ts"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      extension = {
        nu = { glyph = "N", hl = "MiniIconsBlue" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "<leader>n", group = "Node/npm" },
      })
    end,
  },
}

