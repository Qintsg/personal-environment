local palette = {
  bg = "#fafafa",
  bg_dark = "#f0f2f5",
  bg_sidebar = "#f4f4f5",
  bg_status = "#0184bc",
  bg_visual = "#e5e9f0",
  bg_cursor = "#eceff4",
  fg = "#383a42",
  fg_dark = "#6a6d78",
  yellow = "#986801",
  cyan = "#0997b3",
  blue = "#0184bc",
  green = "#50a14f",
  red = "#e45649",
  orange = "#c45a00",
  purple = "#a626a4",
}

local function dashboard_footer()
  local stats = require("lazy").stats()
  local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
  return {
    "ff 查找文件   fr 最近文件   e 文件树   sg 全文搜索   k 快捷键",
    string.format("已加载 %d/%d 个插件，启动耗时 %.2fms", stats.loaded, stats.count, ms),
  }
end

local function set_dashboard_hl()
  vim.api.nvim_set_hl(0, "DashboardHeader", { fg = palette.blue, bold = true })
  vim.api.nvim_set_hl(0, "DashboardDesc", { fg = palette.yellow })
  vim.api.nvim_set_hl(0, "DashboardIcon", { fg = palette.fg_dark })
  vim.api.nvim_set_hl(0, "DashboardKey", { fg = palette.cyan, bold = true })
  vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = palette.cyan })
  vim.api.nvim_set_hl(0, "DashboardFooter", { fg = palette.fg_dark, italic = true })
end

local function root_label()
  local root = vim.fn.fnamemodify(LazyVim.root(), ":~")
  return "  " .. root .. " "
end

local function title_label()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return ""
  end
  return "  " .. name .. " "
end

local function right_label()
  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "text"
  local os_name = vim.loop.os_uname().sysname
  if os_name == "Windows_NT" then
    os_name = "Windows"
  end
  return string.format(" 语法 %s · 系统 %s ", ft, os_name)
end

local function winbar_enabled()
  local ignored = {
    dashboard = true,
    lazy = true,
    mason = true,
    ["neo-tree"] = true,
    trouble = true,
    qf = true,
  }
  return not ignored[vim.bo.filetype]
end

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "day",
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        sidebars = "light",
        floats = "light",
      },
      on_colors = function(colors)
        colors.bg = palette.bg
        colors.bg_dark = palette.bg_dark
        colors.bg_sidebar = palette.bg_sidebar
        colors.bg_float = palette.bg
        colors.bg_statusline = palette.bg_dark
        colors.comment = palette.fg_dark
        colors.border = "#d3d6de"
        colors.blue = palette.blue
        colors.cyan = palette.cyan
        colors.green = palette.green
        colors.yellow = palette.yellow
        colors.orange = palette.orange
        colors.red = palette.red
        colors.purple = palette.purple
      end,
      on_highlights = function(hl)
        hl.Normal = { bg = palette.bg, fg = palette.fg }
        hl.NormalNC = { bg = palette.bg, fg = palette.fg }
        hl.NormalFloat = { bg = palette.bg, fg = palette.fg }
        hl.FloatBorder = { bg = palette.bg, fg = palette.blue }
        hl.FloatTitle = { bg = palette.bg_dark, fg = palette.yellow, bold = true }
        hl.CursorLine = { bg = palette.bg_cursor }
        hl.CursorLineNr = { fg = palette.yellow, bold = true }
        hl.LineNr = { fg = "#a0a3ad" }
        hl.Visual = { bg = palette.bg_visual }
        hl.WinSeparator = { fg = "#d3d6de", bg = palette.bg }
        hl.Search = { bg = "#f4d35e", fg = palette.fg }
        hl.IncSearch = { bg = palette.orange, fg = "#ffffff" }
        hl.StatusLine = { bg = palette.bg_dark, fg = palette.fg }
        hl.StatusLineNC = { bg = palette.bg_dark, fg = palette.fg_dark }
        hl.VertSplit = { fg = "#d3d6de" }
        hl.NeoTreeNormal = { bg = palette.bg_dark, fg = palette.fg }
        hl.NeoTreeNormalNC = { bg = palette.bg_dark, fg = palette.fg }
        hl.NeoTreeEndOfBuffer = { bg = palette.bg_dark, fg = palette.bg_dark }
        hl.NeoTreeCursorLine = { bg = palette.bg_cursor }
        hl.NeoTreeFloatBorder = { bg = palette.bg_dark, fg = palette.blue }
        hl.NeoTreeGitModified = { fg = palette.yellow }
        hl.NeoTreeGitAdded = { fg = palette.green }
        hl.NeoTreeGitDeleted = { fg = palette.red }
        hl.NeoTreeDirectoryIcon = { fg = palette.blue }
        hl.NeoTreeDirectoryName = { fg = palette.blue }
        hl.LualineChip = { bg = palette.yellow, fg = "#ffffff", bold = true }
        hl.LualineTitle = { bg = palette.bg_dark, fg = palette.fg, bold = true }
        hl.LualineMeta = { bg = palette.bg_dark, fg = palette.green, bold = true }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.win = vim.tbl_deep_extend("force", opts.win or {}, {
        border = "rounded",
        wo = { winblend = 8 },
      })
      opts.layout = vim.tbl_deep_extend("force", opts.layout or {}, {
        width = { min = 20, max = 40 },
        spacing = 6,
      })
      opts.spec = vim.list_extend(opts.spec or {}, {
        { "<leader>b", group = "缓冲区" },
        { "<leader>c", group = "代码" },
        { "<leader>f", group = "文件" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>l", group = "插件管理" },
        { "<leader>s", group = "搜索" },
        { "<leader>u", group = "界面" },
        { "<leader>x", group = "诊断/列表" },
      })
    end,
  },

  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      local logo = {
        " ",
        "                    ▟███▙                    ",
        "                   ▟█████▙                   ",
        "                ▟███▛ ▜███▙                  ",
        "               ▟██▛     ▜██▙                 ",
        "               ▜██▙     ▟██▛                 ",
        "                ▜███▙ ▟███▛                  ",
        "                  ▜█████▛                    ",
        "                   VSCODE                    ",
        "                   Qintsg                    ",
        " ",
      }

      opts.theme = "doom"
      opts.hide = vim.tbl_deep_extend("force", opts.hide or {}, {
        statusline = false,
        tabline = false,
      })
      opts.config = opts.config or {}
      opts.config.header = logo
      opts.config.center = {
        { icon = "[f] ", desc = "查找文件", action = 'lua LazyVim.pick("files")()', key = "f" },
        { icon = "[r] ", desc = "最近文件", action = 'lua LazyVim.pick("oldfiles")()', key = "r" },
        { icon = "[e] ", desc = "文件树", action = "Neotree toggle", key = "e" },
        { icon = "[g] ", desc = "全文搜索", action = 'lua LazyVim.pick("live_grep")()', key = "g" },
        { icon = "[n] ", desc = "新建文件", action = "ene | startinsert", key = "n" },
        { icon = "[t] ", desc = "终端", action = 'lua Snacks.terminal()', key = "t" },
        { icon = "[s] ", desc = "恢复会话", action = 'lua require("persistence").load()', key = "s" },
        { icon = "[m] ", desc = "工具管理", action = "Mason", key = "m" },
        { icon = "[k] ", desc = "快捷键提示", action = 'lua require("user.hints").show()', key = "k" },
        { icon = "[l] ", desc = "插件管理", action = "Lazy", key = "l" },
        { icon = "[q] ", desc = "退出 Neovim", action = "qa", key = "q" },
      }
      opts.config.footer = dashboard_footer

      for _, item in ipairs(opts.config.center) do
        item.desc = item.desc .. string.rep(" ", math.max(1, 20 - vim.fn.strdisplaywidth(item.desc)))
        item.key_format = " %s"
      end

      return opts
    end,
    config = function(_, opts)
      set_dashboard_hl()
      require("dashboard").setup(opts)
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.width = 31
      opts.window.mappings = vim.tbl_deep_extend("force", opts.window.mappings or {}, {
        ["h"] = "close_node",
        ["l"] = "open",
        ["<space>"] = "none",
      })
      opts.default_component_configs = vim.tbl_deep_extend("force", opts.default_component_configs or {}, {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "",
        },
        git_status = {
          symbols = {
            added = "●",
            modified = "●",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "◌",
            ignored = "",
            unstaged = "●",
            staged = "■",
            conflict = "",
          },
        },
      })
      opts.filesystem = vim.tbl_deep_extend("force", opts.filesystem or {}, {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local hints = require("user.hints")
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      })

      opts.sections = {
        lualine_a = {
          {
            "mode",
            fmt = function(str)
              return " " .. str .. " "
            end,
            color = { bg = palette.bg_status, fg = palette.bg_dark, gui = "bold" },
          },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { bg = palette.bg_dark, fg = palette.fg },
          },
          {
            function()
              return vim.fn.expand("%:~:.")
            end,
            color = { bg = palette.bg_dark, fg = palette.blue },
          },
        },
        lualine_c = {
          {
            hints.statusline,
            color = hints.color,
            separator = "",
            padding = { left = 1, right = 1 },
            cond = function()
              return vim.o.columns > 110
            end,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
          },
        },
        lualine_y = {
          { "progress", color = { fg = palette.fg, bg = palette.bg_dark } },
        },
        lualine_z = {
          {
            function()
              return os.date("󱑆 %H:%M")
            end,
            color = { bg = palette.bg_status, fg = palette.bg_dark, gui = "bold" },
          },
        },
      }

      opts.winbar = {
        lualine_a = {
          {
            root_label,
            color = "LualineChip",
            separator = { left = "", right = "" },
            cond = winbar_enabled,
            padding = 0,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            title_label,
            color = "LualineTitle",
            separator = { left = "", right = "" },
            cond = function()
              return winbar_enabled() and title_label() ~= ""
            end,
            padding = 0,
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            right_label,
            color = "LualineMeta",
            separator = { left = "", right = "" },
            cond = winbar_enabled,
            padding = 0,
          },
        },
      }

      opts.inactive_winbar = opts.winbar
    end,
  },
}

