local lib = require "custom.lib"
local zh = lib.zh

local M = {}

local footer_timer
local footer_lines = 2

local function highlight(name, value)
    vim.api.nvim_set_hl(0, name, value)
end

local function apply_dashboard_highlights()
    highlight("DashboardHeader", { fg = "#d85858", bold = true })
    highlight("DashboardDesc", { fg = "#e6c384" })
    highlight("DashboardIcon", { fg = "#a6accd" })
    highlight("DashboardKey", { fg = "#7dc4e4", bold = true })
    highlight("DashboardShortCut", { fg = "#7dc4e4" })
    highlight("DashboardFooter", { fg = "#8b8f98", italic = true })
end

local function find_file()
    vim.cmd "Telescope find_files"
end

local function new_file()
    vim.cmd "enew"
    vim.cmd "startinsert"
end

local function recent_files()
    vim.cmd "Telescope oldfiles"
end

local function find_text()
    vim.cmd "Telescope live_grep"
end

local function open_config()
    vim.cmd("edit " .. vim.fn.stdpath "config" .. "/lua/custom/init.lua")
end

local function restore_session()
    require("custom.plugins.session_support").restore()
end

local function lazy_profile()
    vim.cmd "Lazy profile"
end

local function lazy_home()
    vim.cmd "Lazy"
end

local function quit_all()
    vim.cmd "qa"
end

local function menu_item(opts)
    return {
        icon = opts.icon,
        icon_hl = "DashboardIcon",
        desc = opts.desc,
        desc_hl = "DashboardDesc",
        key = opts.key,
        keymap = opts.keymap,
        key_hl = "DashboardKey",
        key_format = "",
        action = opts.action,
    }
end

local function build_footer()
    local ok, dashboard_utils = pcall(require, "dashboard.utils")
    local stats = ok and dashboard_utils.get_package_manager_stats() or { loaded = 0, count = 0, time = 0 }
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    return {
        string.format("Plugins %d/%d   Startup %.2fms", stats.loaded or 0, stats.count or 0, stats.time or 0),
        string.format("Time %s   CWD %s", os.date "%Y-%m-%d %H:%M", cwd),
    }
end

local function update_footer(bufnr)
    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
        return
    end
    if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) ~= "dashboard" then
        return
    end

    local ok, dashboard_utils = pcall(require, "dashboard.utils")
    if not ok then
        return
    end

    local lines = dashboard_utils.center_align(build_footer())
    local total = vim.api.nvim_buf_line_count(bufnr)
    local start_line = math.max(total - footer_lines, 0)

    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, start_line, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].modified = false

    for idx = start_line, start_line + #lines - 1 do
        vim.api.nvim_buf_add_highlight(bufnr, 0, "DashboardFooter", idx, 0, -1)
    end
end

local function stop_footer_timer()
    if footer_timer then
        footer_timer:stop()
        footer_timer:close()
        footer_timer = nil
    end
end

local function start_footer_timer(bufnr)
    stop_footer_timer()

    footer_timer = vim.uv.new_timer()
    if not footer_timer then
        return
    end

    footer_timer:start(0, 30000, vim.schedule_wrap(function()
        update_footer(bufnr)
    end))

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufLeave" }, {
        buffer = bufnr,
        once = true,
        callback = stop_footer_timer,
    })
end

Ice.keymap.recent_files = { "n", "<leader>tr", "<Cmd>Telescope oldfiles<CR>", { desc = zh(26368, 36817, 25991, 20214) } }
Ice.keymap.new_file = { "n", "<leader>fn", new_file, { desc = zh(26032, 24314, 25991, 20214) } }
Ice.keymap.lazy_home = { "n", "<leader>uL", "<Cmd>Lazy<CR>", { desc = "Lazy " .. zh(25554, 20214, 31649, 29702) } }

Ice.plugins.dashboard.opts.config.header = {
    " ",
    "鈻堚枅鈺?  鈻堚枅鈺椻枅鈻堚枅鈻堚枅鈻堚枅鈺?鈻堚枅鈻堚枅鈻堚枅鈺?鈻堚枅鈻堚枅鈻堚枅鈺?鈻堚枅鈻堚枅鈻堚枅鈺?鈻堚枅鈻堚枅鈻堚枅鈻堚晽",
    "鈻堚枅鈺?  鈻堚枅鈺戔枅鈻堚晹鈺愨晲鈺愨晲鈺濃枅鈻堚晹鈺愨晲鈺愨晲鈺濃枅鈻堚晹鈺愨晲鈺愨枅鈻堚晽鈻堚枅鈺斺晲鈺愨枅鈻堚晽鈻堚枅鈺斺晲鈺愨晲鈺愨暆",
    "鈻堚枅鈺?  鈻堚枅鈺戔枅鈻堚枅鈻堚枅鈻堚枅鈺椻枅鈻堚晳     鈻堚枅鈺?  鈻堚枅鈺戔枅鈻堚晳  鈻堚枅鈺戔枅鈻堚枅鈻堚枅鈺? ",
    "鈺氣枅鈻堚晽 鈻堚枅鈺斺暆鈺氣晲鈺愨晲鈺愨枅鈻堚晳鈻堚枅鈺?    鈻堚枅鈺?  鈻堚枅鈺戔枅鈻堚晳  鈻堚枅鈺戔枅鈻堚晹鈺愨晲鈺? ",
    " 鈺氣枅鈻堚枅鈻堚晹鈺?鈻堚枅鈻堚枅鈻堚枅鈻堚晳鈺氣枅鈻堚枅鈻堚枅鈻堚晽鈺氣枅鈻堚枅鈻堚枅鈻堚晹鈺濃枅鈻堚枅鈻堚枅鈻堚晹鈺濃枅鈻堚枅鈻堚枅鈻堚枅鈺?,
    "  鈺氣晲鈺愨晲鈺? 鈺氣晲鈺愨晲鈺愨晲鈺愨暆 鈺氣晲鈺愨晲鈺愨晲鈺?鈺氣晲鈺愨晲鈺愨晲鈺?鈺氣晲鈺愨晲鈺愨晲鈺?鈺氣晲鈺愨晲鈺愨晲鈺愨暆",
    " ",
    "                 QINTSG                 ",
    " ",
}

Ice.plugins.dashboard.opts.config.center = {
    menu_item {
        icon = "[f] ",
        desc = "Find File " .. zh(26597, 25214, 25991, 20214),
        key = "f",
        keymap = "SPC t f",
        action = find_file,
    },
    menu_item {
        icon = "[n] ",
        desc = "New File " .. zh(26032, 24314, 25991, 20214),
        key = "n",
        keymap = "SPC f n",
        action = new_file,
    },
    menu_item {
        icon = "[r] ",
        desc = "Recent Files " .. zh(26368, 36817, 25991, 20214),
        key = "r",
        keymap = "SPC t r",
        action = recent_files,
    },
    menu_item {
        icon = "[g] ",
        desc = "Find Text " .. zh(26597, 25214, 25991, 26412),
        key = "g",
        keymap = "SPC t<C-f>",
        action = find_text,
    },
    menu_item {
        icon = "[c] ",
        desc = "Config " .. zh(37197, 32622),
        key = "c",
        keymap = "SPC u c",
        action = open_config,
    },
    menu_item {
        icon = "[s] ",
        desc = "Restore Session " .. zh(24674, 22797, 20250, 35805),
        key = "s",
        keymap = "SPC u s",
        action = restore_session,
    },
    menu_item {
        icon = "[x] ",
        desc = "Lazy Profile " .. zh(24615, 33021, 20998, 26512),
        key = "x",
        keymap = "SPC u l",
        action = lazy_profile,
    },
    menu_item {
        icon = "[l] ",
        desc = "Lazy " .. zh(25554, 20214, 31649, 29702),
        key = "l",
        keymap = "SPC u L",
        action = lazy_home,
    },
    menu_item {
        icon = "[q] ",
        desc = "Quit " .. zh(36864, 20986),
        key = "q",
        keymap = ":qa",
        action = quit_all,
    },
}

Ice.plugins.dashboard.opts.config.footer = build_footer
Ice.plugins.dashboard.opts.config.vertical_center = true

local has_file_group = false
for _, spec in ipairs(Ice.plugins["which-key"].opts.spec) do
    if spec[1] == "<leader>f" then
        spec.group = "+" .. zh(25991, 20214)
        has_file_group = true
        break
    end
end
if not has_file_group then
    table.insert(Ice.plugins["which-key"].opts.spec, { "<leader>f", group = "+" .. zh(25991, 20214) })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_dashboard_highlights,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "DashboardLoaded",
    callback = function(ev)
        apply_dashboard_highlights()
        start_footer_timer((ev and ev.buf and ev.buf > 0) and ev.buf or vim.api.nvim_get_current_buf())
    end,
})

M.build_footer = build_footer
M.update_footer = update_footer
M.stop_footer_timer = stop_footer_timer

return M
