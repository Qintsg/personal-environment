return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "查找并替换",
      },
    },
    opts = {
      startInInsertMode = true,
      disableBufferLineNumbers = true,
      folding = { enabled = true },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.mappings = vim.tbl_deep_extend("force", opts.window.mappings or {}, {
        ["h"] = "close_node",
        ["l"] = "open",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            vim.fn.setreg("+", node:get_id(), "c")
          end,
          desc = "复制路径到剪贴板",
        },
      })
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          never_show = { ".DS_Store", "thumbs.db" },
        },
      })
    end,
  },
}

