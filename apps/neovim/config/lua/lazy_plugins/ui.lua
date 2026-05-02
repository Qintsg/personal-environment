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
    "ff 鏌ユ壘鏂囦欢   fr 鏈€杩戞枃浠?  e 鏂囦欢鏍?  sg 鍏ㄦ枃鎼滅储   k 蹇嵎閿?,
    string.format("宸插姞杞?%d/%d 涓彃浠讹紝鍚姩鑰楁椂 %.2fms", stats.loaded, stats.count, ms),
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
  return " 飦?" .. root .. " "
end

local function title_label()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return ""
  end
  return " 飬?" .. name .. " "
end

local function right_label()
  local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "text"
  local os_name = vim.loop.os_uname().sysname
  if os_name == "Windows_NT" then
    os_name = "Windows"
  end
  return string.format(" 璇硶 %s 路 绯荤粺 %s ", ft, os_name)
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
        { "<leader>b", group = "缂撳啿鍖? },
        { "<leader>c", group = "浠ｇ爜" },
        { "<leader>f", group = "鏂囦欢" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>l", group = "鎻掍欢绠＄悊" },
        { "<leader>s", group = "鎼滅储" },
        { "<leader>u", group = "鐣岄潰" },
        { "<leader>x", group = "璇婃柇/鍒楄〃" },
      })
    end,
  },

  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      local logo = {
        " ",
        "                    鈻熲枅鈻堚枅鈻?                   ",
        "                   鈻熲枅鈻堚枅鈻堚枅鈻?                  ",
        "                鈻熲枅鈻堚枅鈻?鈻溾枅鈻堚枅鈻?                 ",
        "               鈻熲枅鈻堚枦     鈻溾枅鈻堚枡                 ",
        "               鈻溾枅鈻堚枡     鈻熲枅鈻堚枦                 ",
        "                鈻溾枅鈻堚枅鈻?鈻熲枅鈻堚枅鈻?                 ",
        "                  鈻溾枅鈻堚枅鈻堚枅鈻?                   ",
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
        { icon = "[f] ", desc = "鏌ユ壘鏂囦欢", action = 'lua LazyVim.pick("files")()', key = "f" },
        { icon = "[r] ", desc = "鏈€杩戞枃浠?, action = 'lua LazyVim.pick("oldfiles")()', key = "r" },
        { icon = "[e] ", desc = "鏂囦欢鏍?, action = "Neotree toggle", key = "e" },
        { icon = "[g] ", desc = "鍏ㄦ枃鎼滅储", action = 'lua LazyVim.pick("live_grep")()', key = "g" },
        { icon = "[n] ", desc = "鏂板缓鏂囦欢", action = "ene | startinsert", key = "n" },
        { icon = "[t] ", desc = "缁堢", action = 'lua Snacks.terminal()', key = "t" },
        { icon = "[s] ", desc = "鎭㈠浼氳瘽", action = 'lua require("persistence").load()', key = "s" },
        { icon = "[m] ", desc = "宸ュ叿绠＄悊", action = "Mason", key = "m" },
        { icon = "[k] ", desc = "蹇嵎閿彁绀?, action = 'lua require("user.hints").show()', key = "k" },
        { icon = "[l] ", desc = "鎻掍欢绠＄悊", action = "Lazy", key = "l" },
        { icon = "[q] ", desc = "閫€鍑?Neovim", action = "qa", key = "q" },
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
          expander_collapsed = "飸?,
          expander_expanded = "飸?,
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "顥?,
          folder_open = "顥?,
          folder_empty = "飷?,
          default = "顦?,
        },
        git_status = {
          symbols = {
            added = "鈼?,
            modified = "鈼?,
            deleted = "鉁?,
            renamed = "蟀仌",
            untracked = "鈼?,
            ignored = "飸?,
            unstaged = "鈼?,
            staged = "鈻?,
            conflict = "顪?,
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
            icon = "飷?,
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
            symbols = { error = "飦?", warn = "飦?", info = "飦?", hint = "飪?" },
          },
          {
            "diff",
            symbols = { added = "飪?", modified = "飬?", removed = "飬?" },
          },
        },
        lualine_y = {
          { "progress", color = { fg = palette.fg, bg = palette.bg_dark } },
        },
        lualine_z = {
          {
            function()
              return os.date("蟊憜 %H:%M")
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
            separator = { left = "顐?, right = "顐? },
            cond = winbar_enabled,
            padding = 0,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            title_label,
            color = "LualineTitle",
            separator = { left = "顐?, right = "顐? },
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
            separator = { left = "顐?, right = "顐? },
            cond = winbar_enabled,
            padding = 0,
          },
        },
      }

      opts.inactive_winbar = opts.winbar
    end,
  },
}

