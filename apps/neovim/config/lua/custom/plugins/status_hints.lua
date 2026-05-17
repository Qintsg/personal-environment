local zh = require("custom.lib").zh

local M = {}

local function filetype()
    return vim.bo.filetype
end

local function width()
    return vim.o.columns
end

local function mode()
    return vim.api.nvim_get_mode().mode
end

local function has_lsp()
    local clients = vim.lsp.get_clients { bufnr = 0 }
    for _, client in ipairs(clients) do
        if client.name ~= "null-ls" then
            return true
        end
    end
    return false
end

local function is_code_file(ft)
    return vim.tbl_contains({
        "lua",
        "python",
        "javascript",
        "typescript",
        "typescriptreact",
        "javascriptreact",
        "tsx",
        "vue",
        "go",
        "rust",
        "c",
        "cpp",
        "cs",
        "css",
        "html",
        "json",
        "yaml",
        "toml",
        "bash",
        "sh",
    }, ft)
end

local function join_hints(items)
    local parts = {}
    local limit = math.max(width() - 20, 60)
    local sep = "  |  "

    for _, item in ipairs(items) do
        local candidate = (#parts == 0) and item or (table.concat(parts, sep) .. sep .. item)
        if vim.fn.strdisplaywidth(candidate) > limit then
            break
        end
        parts[#parts + 1] = item
    end

    return table.concat(parts, sep)
end

local function lazy_mode()
    local ok, view = pcall(require, "lazy.view")
    if not ok or not view.view or view.view.buf ~= vim.api.nvim_get_current_buf() then
        return nil
    end
    return view.view.state and view.view.state.mode or "home"
end

local function mason_mode()
    if filetype() ~= "mason" then
        return nil
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, 25, false)
    local text = table.concat(lines, "\n")
    if text:find("Mason log", 1, true)
        or text:find("Keyboard shortcuts", 1, true)
        or text:find("蹇嵎閿?, 1, true)
        or text:find("鍖呮潵婧愪簬浠ヤ笅娉ㄥ唽婧?, 1, true)
    then
        return "help"
    end
    return "main"
end

local function page_hints()
    local ft = filetype()
    local m = mode()

    if ft == "dashboard" then
        return {
            "SPC t f " .. zh(26597, 25214, 25991, 20214),
            "SPC f n " .. zh(26032, 24314, 25991, 20214),
            "SPC t r " .. zh(26368, 36817, 25991, 20214),
            "SPC t<C-f> " .. zh(20840, 25991, 25628, 32034),
            "SPC u c Config",
            "SPC u s " .. zh(24674, 22797, 20250, 35805),
            "SPC u L Lazy",
            ":qa " .. zh(36864, 20986),
        }
    end

    if ft == "lazy" then
        local mode = lazy_mode() or "home"
        if mode == "help" then
            return {
                "? " .. zh(20999, 25442, 24110, 21161),
                "<CR> " .. zh(25554, 20214, 35814, 24773),
                "K " .. zh(25171, 24320, 38142, 25509, 25110, 24110, 21161),
                "<d> diff",
                "<]]>/<[[> " .. zh(25554, 20214, 23548, 33322),
                "q " .. zh(20851, 38381),
            }
        elseif mode == "profile" then
            return {
                "<C-s> " .. zh(20999, 25442, 25490, 24207),
                "<C-f> " .. zh(35774, 32622, 38408, 20540),
                "H " .. zh(39318, 39029),
                "D " .. zh(35843, 35797),
                "q " .. zh(20851, 38381),
            }
        elseif mode == "debug" then
            return {
                "H " .. zh(39318, 39029),
                "P " .. zh(24615, 33021, 20998, 26512),
                "? " .. zh(24110, 21161),
                "q " .. zh(20851, 38381),
            }
        else
            return {
                "H " .. zh(39318, 39029),
                "I " .. zh(23433, 35013),
                "U " .. zh(26356, 26032),
                "S " .. zh(21516, 27493),
                "X " .. zh(28165, 29702),
                "P " .. zh(24615, 33021, 20998, 26512),
                "D " .. zh(35843, 35797),
                "? " .. zh(24110, 21161),
                "q " .. zh(20851, 38381),
            }
        end
    end

    if ft == "mason" then
        local mode = mason_mode()
        if mode == "help" then
            return {
                "g? " .. zh(36820, 22238, 21253, 21015, 34920),
                "1-5 " .. zh(20999, 25442, 35270, 22270),
                "<C-f> " .. zh(35821, 35328, 31579, 36873),
                "<Esc> " .. zh(28165, 38500, 31579, 36873),
                "q " .. zh(20851, 38381),
            }
        end
        return {
            "<CR> " .. zh(23637, 24320, 21253, 20449, 24687),
            "i " .. zh(23433, 35013),
            "u/U " .. zh(26356, 26032),
            "c/C " .. zh(26816, 26597, 29256, 26412),
            "X " .. zh(21368, 36733),
            "<C-f> " .. zh(35821, 35328, 31579, 36873),
            "g? " .. zh(24110, 21161),
            "q " .. zh(20851, 38381),
        }
    end

    if ft == "NvimTree" then
        return {
            "<CR> " .. zh(25171, 24320),
            "a " .. zh(26032, 24314),
            "r " .. zh(37325, 21629, 21517),
            "d " .. zh(21024, 38500),
            "y " .. zh(22797, 21046),
            "p " .. zh(31896, 36148),
            ". " .. zh(26174, 31034, 38544, 34255),
            "F5 " .. zh(21047, 26032),
        }
    end

    if ft == "markdown" then
        if m:find("i", 1, true) == 1 then
            return {
                "Esc " .. zh(26222, 36890),
                "Ctrl+s " .. zh(20445, 23384),
                ":q " .. zh(36864, 20986),
                "Alt+b " .. zh(39044, 35272),
                "SPC t<C-f> " .. zh(20840, 25991, 25628, 32034),
            }
        end
        return {
            "i/a/o/O " .. zh(32534, 36753),
            "Alt+b " .. zh(39044, 35272),
            "Ctrl+s " .. zh(20445, 23384),
            ":q " .. zh(36864, 20986),
            "SPC t<C-f> " .. zh(20840, 25991, 25628, 32034),
        }
    end

    if ft == "terminal" or vim.bo.buftype == "terminal" then
        return {
            "Esc " .. zh(36864, 22238, 26222, 36890, 27169, 24335),
            "Ctrl+t " .. zh(25171, 24320, 32456, 31471),
            "Ctrl+z " .. zh(25764, 38144),
        }
    end

    if m:find("i", 1, true) == 1 then
        if is_code_file(ft) then
            return {
                "Esc " .. zh(26222, 36890),
                "Ctrl+s " .. zh(20445, 23384),
                "lr " .. zh(37325, 21629, 21517),
                ":q " .. zh(36864, 20986),
            }
        end
        return {
            "Esc " .. zh(36864, 22238, 26222, 36890),
            "Ctrl+s " .. zh(20445, 23384),
            ":q " .. zh(36864, 20986),
            "Ctrl+z " .. zh(25764, 38144),
            ":wq " .. zh(20445, 23384, 24182, 36864, 20986),
        }
    end

    if m == "v" or m == "V" or m == "\22" then
        if has_lsp() and is_code_file(ft) then
            return {
                "<leader>lf " .. zh(26684, 24335, 21270, 36873, 21306),
                "J " .. zh(21512, 24182, 36873, 21306),
                "\\ " .. zh(40657, 27934, 21098, 23384),
                "gcc " .. zh(27880, 37322, 36873, 21306),
                "Ctrl+s " .. zh(20445, 23384),
            }
        end
        return {
            "J " .. zh(21512, 24182, 36873, 21306),
            "\\ " .. zh(40657, 27934, 21098, 23384),
            "gcc " .. zh(27880, 37322, 36873, 21306),
            "Ctrl+s " .. zh(20445, 23384),
        }
    end

    if is_code_file(ft) then
        return {
            "i/a/o/O " .. zh(32534, 36753),
            "Ctrl+s " .. zh(20445, 23384),
            "lr " .. zh(37325, 21629, 21517),
            ":q " .. zh(36864, 20986),
        }
    end

    return {
        "i/a/o/O " .. zh(32534, 36753),
        "Ctrl+s " .. zh(20445, 23384),
        "gcc " .. zh(27880, 37322),
        ":q " .. zh(36864, 20986),
        ":wq " .. zh(20445, 23384, 24182, 36864, 20986),
    }
end

function M.component()
    return join_hints(page_hints())
end

function M.color()
    local ft = filetype()
    if ft == "dashboard" then
        return { fg = "#f3e5c4", bg = "#222733" }
    elseif ft == "lazy" or ft == "mason" then
        return { fg = "#d8dee9", bg = "#1f2430" }
    end
    return { fg = "#c0c7d1", bg = "#1a1f2a" }
end

Ice.plugins.dashboard.opts.hide = vim.tbl_deep_extend("force", Ice.plugins.dashboard.opts.hide or {}, {
    statusline = false,
    tabline = false,
})

local lualine_opts = Ice.plugins.lualine.opts
lualine_opts.options.globalstatus = true
lualine_opts.sections.lualine_a = { "mode" }
lualine_opts.sections.lualine_b = { "branch", "diff" }
lualine_opts.sections.lualine_c = {
    {
        M.component,
        color = M.color,
        separator = "",
        padding = { left = 1, right = 1 },
    },
}
lualine_opts.sections.lualine_x = {
    {
        "filename",
        path = 1,
    },
    "filesize",
    {
        "fileformat",
        symbols = {
            unix = Ice.symbols.Unix,
            dos = Ice.symbols.Dos,
            mac = Ice.symbols.Mac,
        },
    },
    "encoding",
    "filetype",
}
lualine_opts.sections.lualine_y = {}
lualine_opts.sections.lualine_z = { "location" }

return M
