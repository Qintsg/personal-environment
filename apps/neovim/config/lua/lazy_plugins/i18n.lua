return {
  {
    "folke/lazy.nvim",
    init = function()
      pcall(require, "custom.plugins.lazy_i18n")
    end,
  },

  {
    "mason-org/mason.nvim",
    init = function()
      pcall(require, "custom.plugins.mason_i18n")
    end,
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "<leader>qq", desc = "退出全部" },
        { "<leader>bd", desc = "关闭当前缓冲区" },
        { "<leader>ff", desc = "查找文件" },
        { "<leader>fr", desc = "最近文件" },
        { "<leader>sg", desc = "全文搜索" },
        { "<leader>e", desc = "切换文件树" },
        { "<leader>fm", desc = "格式化文件" },
        { "<leader>ca", desc = "代码操作" },
        { "<leader>cr", desc = "重命名符号" },
        { "<leader>l", desc = "插件管理" },
        { "<leader>cm", desc = "工具管理" },
        { "<leader>uh", desc = "快捷键总览" },
        { "<leader>uN", desc = "Neovide 快捷键" },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        prompt_prefix = "   ",
        selection_caret = "   ",
        results_title = false,
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
      })

      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = { prompt_title = "查找文件" },
        oldfiles = { prompt_title = "最近文件" },
        live_grep = { prompt_title = "全文搜索" },
        buffers = { prompt_title = "缓冲区" },
        diagnostics = { prompt_title = "诊断信息" },
        command_history = { prompt_title = "命令历史" },
        search_history = { prompt_title = "搜索历史" },
        help_tags = { prompt_title = "帮助文档" },
        keymaps = { prompt_title = "快捷键" },
        colorscheme = { prompt_title = "主题预览" },
      })
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.title = "文件树"
    end,
  },
}

