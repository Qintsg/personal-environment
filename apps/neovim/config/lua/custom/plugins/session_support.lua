local lib = require "custom.lib"
local zh = lib.zh

local M = {}

local session_dir = vim.fs.joinpath(vim.fn.stdpath "state", "sessions")
local session_file = vim.fs.joinpath(session_dir, "last.vim")

local function ensure_session_dir()
    if not vim.uv.fs_stat(session_dir) then
        vim.fn.mkdir(session_dir, "p")
    end
end

local function has_real_buffers()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
            local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
            if name ~= "" and buftype == "" and filetype ~= "dashboard" then
                return true
            end
        end
    end
    return false
end

function M.save()
    if not has_real_buffers() then
        return false
    end

    ensure_session_dir()
    vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session_file))
    return true
end

function M.restore()
    if not vim.uv.fs_stat(session_file) then
        vim.notify(zh(26410, 25214, 21040, 21487, 24674, 22797, 30340, 20250, 35805), vim.log.levels.INFO)
        return
    end

    vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
    vim.notify(zh(24050, 24674, 22797, 20250, 35805), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("IceSessionRestore", M.restore, { nargs = 0 })
vim.api.nvim_create_user_command("IceSessionSave", function()
    if M.save() then
        vim.notify(zh(24050, 20445, 23384, 20250, 35805), vim.log.levels.INFO)
    else
        vim.notify(zh(27809, 26377, 21487, 20445, 23384, 30340, 20250, 35805, 20869, 23481), vim.log.levels.WARN)
    end
end, { nargs = 0 })

vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        M.save()
    end,
})

Ice.keymap.restore_session = {
    "n",
    "<leader>us",
    function()
        require("custom.plugins.session_support").restore()
    end,
    { desc = zh(24674, 22797, 20250, 35805) },
}

Ice.keymap.save_session = {
    "n",
    "<leader>uS",
    function()
        require("custom.plugins.session_support").save()
    end,
    { desc = zh(20445, 23384, 20250, 35805) },
}

return M
