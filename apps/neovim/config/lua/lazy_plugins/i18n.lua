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
        { "<leader>qq", desc = "閫€鍑哄叏閮? },
        { "<leader>bd", desc = "鍏抽棴褰撳墠缂撳啿鍖? },
        { "<leader>ff", desc = "鏌ユ壘鏂囦欢" },
        { "<leader>fr", desc = "鏈€杩戞枃浠? },
        { "<leader>sg", desc = "鍏ㄦ枃鎼滅储" },
        { "<leader>e", desc = "鍒囨崲鏂囦欢鏍? },
        { "<leader>fm", desc = "鏍煎紡鍖栨枃浠? },
        { "<leader>ca", desc = "浠ｇ爜鎿嶄綔" },
        { "<leader>cr", desc = "閲嶅懡鍚嶇鍙? },
        { "<leader>l", desc = "鎻掍欢绠＄悊" },
        { "<leader>cm", desc = "宸ュ叿绠＄悊" },
        { "<leader>uh", desc = "蹇嵎閿€昏" },
        { "<leader>uN", desc = "Neovide 蹇嵎閿? },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        prompt_prefix = " 飥? ",
        selection_caret = " 飦? ",
        results_title = false,
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
      })

      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        find_files = { prompt_title = "鏌ユ壘鏂囦欢" },
        oldfiles = { prompt_title = "鏈€杩戞枃浠? },
        live_grep = { prompt_title = "鍏ㄦ枃鎼滅储" },
        buffers = { prompt_title = "缂撳啿鍖? },
        diagnostics = { prompt_title = "璇婃柇淇℃伅" },
        command_history = { prompt_title = "鍛戒护鍘嗗彶" },
        search_history = { prompt_title = "鎼滅储鍘嗗彶" },
        help_tags = { prompt_title = "甯姪鏂囨。" },
        keymaps = { prompt_title = "蹇嵎閿? },
        colorscheme = { prompt_title = "涓婚棰勮" },
      })
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.title = "鏂囦欢鏍?
    end,
  },
}

