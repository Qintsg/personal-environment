local zh = require("custom.lib").zh

local function patch_lazy_ui()
    local ok_core_config, lazy_core_config = pcall(require, "lazy.core.config")
    if ok_core_config and lazy_core_config and lazy_core_config.options and lazy_core_config.options.ui then
        lazy_core_config.options.ui.title = "Lazy " .. zh(25554, 20214, 31649, 29702)
    end

    local ok_util, lazy_util = pcall(require, "lazy.util")
    if ok_util and not lazy_util._zh_error_patched then
        local old_error = lazy_util.error
        local error_replacements = {
            ["Please input a number"] = zh(35831, 36755, 20837, 25968, 23383),
            ["Invalid lazy command '"] = zh(26080, 25928, 30340, 32) .. "Lazy " .. zh(21629, 20196, 65306) .. "'",
        }
        lazy_util.error = function(msg, ...)
            for from, to in pairs(error_replacements) do
                if msg == from then
                    msg = to
                    break
                elseif msg:find(from, 1, true) == 1 then
                    msg = to .. msg:sub(#from + 1)
                    break
                end
            end
            return old_error(msg, ...)
        end
        lazy_util._zh_error_patched = true
    end

    if not vim.g._lazy_zh_input_patched then
        local old_input = vim.ui.input
        vim.ui.input = function(opts, on_confirm)
            if opts and opts.prompt == "Enter time threshold in ms: " then
                opts = vim.tbl_extend("force", opts, {
                    prompt = zh(36755, 20837, 32791, 38388, 38408, 20540, 65288, 27627, 31186, 65289, 65306, 32),
                })
            end
            return old_input(opts, on_confirm)
        end
        vim.g._lazy_zh_input_patched = true
    end

    local ok_config, view_config = pcall(require, "lazy.view.config")
    if ok_config and view_config and view_config.commands then
        local command_replacements = {
            home = zh(36820, 22238, 21040, 25554, 20214, 21015, 34920),
            install = zh(23433, 35013, 32570, 22833, 30340, 25554, 20214),
            update = zh(26356, 26032, 25554, 20214, 24182, 38145, 23450, 25991, 20214),
            sync = zh(21516, 27493, 23433, 35013, 12289, 28165, 29702, 21644, 26356, 26032),
            clean = zh(28165, 29702, 25554, 20214),
            check = zh(26816, 26597, 26356, 26032),
            log = zh(26356, 26032, 26085, 24535),
            restore = zh(24674, 22797, 38145, 23450, 29366, 24577),
            profile = zh(26174, 31034, 35814, 32454, 24615, 33021, 20998, 26512),
            debug = zh(26174, 31034, 35843, 35797, 20449, 24687),
            help = zh(20999, 25442, 24110, 21161, 39029),
            clear = zh(28165, 38500, 24050, 23436, 25104, 30340, 20219, 21153),
            load = zh(21152, 36733, 23578, 26410, 21152, 36733, 30340, 25554, 20214),
            health = zh(25191, 34892, 32) .. ":checkhealth lazy",
            build = zh(37325, 24314, 25554, 20214),
            reload = zh(37325, 26032, 21152, 36733, 25554, 20214),
        }
        local plugin_command_replacements = {
            install = zh(23433, 35013, 25554, 20214),
            update = zh(26356, 26032, 25554, 20214, 24182, 38145, 23450, 25991, 20214),
            sync = zh(25191, 34892, 23433, 35013, 12289, 28165, 29702, 21644, 26356, 26032),
            clean = zh(21024, 38500, 25554, 20214, 65288, 27880, 24847, 65306, 21363, 20351, 24212, 35813, 23433, 35013, 20063, 20250, 34987, 21024, 38500, 65289),
            check = zh(26816, 26597, 26356, 26032, 24182, 26174, 31034, 26085, 24535),
            log = zh(26174, 31034, 26368, 36817, 26356, 26032),
            restore = zh(24674, 22797, 25554, 20214, 21040, 38145, 23450, 25991, 20214, 25110, 20809, 26631, 19979, 30340, 25351, 23450, 25552, 20132, 29366, 24577),
        }
        for name, text in pairs(command_replacements) do
            if view_config.commands[name] then
                view_config.commands[name].desc = text
                if plugin_command_replacements[name] then
                    view_config.commands[name].desc_plugin = plugin_command_replacements[name]
                elseif view_config.commands[name].desc_plugin then
                    view_config.commands[name].desc_plugin = text
                end
            end
        end
    end

    local ok_sections, sections = pcall(require, "lazy.view.sections")
    if ok_sections and type(sections) == "table" then
        local section_replacements = {
            Failed = zh(22833, 36133),
            Working = zh(36816, 34892, 20013),
            Build = zh(26500, 24314),
            ["Breaking Changes"] = zh(30772, 22351, 24615, 26356),
            Updated = zh(24050, 26356, 26032),
            Installed = zh(24050, 23433, 35013),
            Updates = zh(21487, 26356, 26032),
            Log = zh(26085, 24535),
            Clean = zh(28165, 29702),
            ["Not Installed"] = zh(26410, 23433, 35013),
            Outdated = zh(24050, 36807, 26399),
            Loaded = zh(24050, 21152, 36733),
            ["Not Loaded"] = zh(26410, 21152, 36733),
            Disabled = zh(24050, 31105, 29992),
        }
        for _, section in ipairs(sections) do
            if section_replacements[section.title] then
                section.title = section_replacements[section.title]
            end
        end
    end

    local ok_text, text = pcall(require, "lazy.view.text")
    if not ok_text or text._zh_append_patched then
        return
    end

    local old_append = text.append
    local replacements = {
        ["Home"] = zh(39318, 39029),
        ["Install"] = zh(23433, 35013),
        ["Update"] = zh(26356, 26032),
        ["Sync"] = zh(21516, 27493),
        ["Clean"] = zh(28165, 29702),
        ["Check"] = zh(26816, 26597),
        ["Log"] = zh(26085, 24535),
        ["Restore"] = zh(24674, 22797),
        ["Profile"] = zh(24615, 33021, 20998, 26512),
        ["Debug"] = zh(35843, 35797),
        ["Help"] = zh(24110, 21161),
        ["Clear"] = zh(28165, 38500),
        ["Load"] = zh(21152, 36733),
        ["Health"] = zh(20581, 24247, 26816, 26597),
        ["Build"] = zh(26500, 24314),
        ["Reload"] = zh(37325, 26032, 21152, 36733),
        ["Tasks: "] = zh(20219, 21153, 65306),
        ["Total: "] = zh(24635, 25968, 65306),
        ["Use "] = zh(20351, 29992, 32),
        [" to abort all running tasks."] = zh(32, 20013, 27490, 25152, 26377, 36816, 34892, 20013, 20219, 21153, 12290),
        ["You can press "] = zh(20320, 21487, 25353, 19979, 32),
        [" on a plugin to show its details."] = zh(32, 22312, 25554, 20214, 19978, 26174, 31034, 35814, 24773, 35814, 32454, 12290),
        ["Most properties can be hovered with "] = zh(22823, 22810, 25968, 23646, 21487, 36890, 36807, 32),
        [" to open links, help files, readmes and git commits."] = zh(32, 25171, 24320, 38142, 25509, 12289, 24110, 21161, 25991, 20214, 12289, 82, 69, 65, 68, 77, 69, 21644, 71, 105, 116, 25552, 20132, 12290),
        ["When hovering with "] = zh(24403, 20351, 29992, 32),
        [" on a plugin anywhere else, a diff will be opened if there are updates"] = zh(32, 22312, 25554, 20214, 21306, 22495, 30340, 20219, 24847, 20301, 32622, 20572, 20572, 65292, 22914, 26524, 26377, 26356, 26032, 21017, 25171, 24320, 32, 100, 105, 102, 102),
        ["or the plugin was just updated. Otherwise the plugin webpage will open."] = zh(25110, 35813, 25554, 20214, 21018, 21018, 34987, 26356, 26032, 12290, 21542, 21017, 23558, 25171, 24320, 25554, 20214, 32593, 39029, 12290),
        [" on a commit or plugin to open the diff view"] = zh(32, 22312, 25552, 20132, 25110, 25554, 20214, 19978, 25171, 24320, 32, 100, 105, 102, 102, 32, 35270, 22270),
        [" and "] = zh(32, 21644, 32),
        [" to navigate between plugins"] = zh(32, 22312, 25554, 20214, 20043, 38388, 23548, 33322),
        ["Keyboard Shortcuts"] = zh(24555, 38190, 24555, 25463),
        ["Keyboard Shortcuts for Plugins"] = zh(25554, 20214, 30456, 20851, 24555, 38190, 24555, 25463),
        ["Custom key "] = zh(33258, 23450, 20041, 25353, 38190, 32),
        ["Active Handlers"] = zh(27963, 21160, 20013, 30340, 22788, 29702, 22120),
        ["This shows only the lazy handlers that are still active. When a plugin loads, its handlers are removed"] = zh(36825, 37324, 21482, 26174, 31034, 20173, 20173, 27963, 21160, 30340, 32, 108, 97, 122, 121, 32, 22788, 29702, 22120, 12290, 24403, 25554, 20214, 34987, 21152, 36733, 21518, 65292, 23545, 24212, 30340, 22788, 29702, 22120, 20250, 34987, 31227, 38500),
        ["Startuptime: "] = zh(21551, 21160, 32791, 26102, 65306),
        ["Based on the actual CPU time of the Neovim process till "] = zh(22522, 20110, 20102, 32467, 21040, 32, 78, 101, 111, 118, 105, 109, 32, 36827, 31243),
        ["This is more accurate than "] = zh(36825, 27604, 32),
        ["An accurate startuptime based on the actual CPU time of the Neovim process is not available."] = zh(26080, 27861, 33719, 21462, 22522, 20110, 78, 101, 111, 118, 105, 109, 36827, 31243, 23454, 38469, 67, 80, 85, 26102, 38388, 30340, 31934, 30830, 21551, 21160, 32791, 26102, 12290),
        ["Startuptime is instead based on a delta with a timestamp when lazy started till "] = zh(24403, 21069, 25968, 20540, 25913, 25454, 32, 108, 97, 122, 121, 32, 21551, 21160, 21040, 32),
        [" to change sorting between chronological order & time taken."] = zh(32, 21487, 22312, 25442, 25353, 26102, 38388, 25490, 24207, 21644, 25353, 26102, 39034, 24207, 12290),
        ["Press "] = zh(25353, 19979, 32),
        [" to filter profiling entries that took more time than a given threshold"] = zh(32, 21487, 36807, 28388, 21482, 36229, 36215, 38408, 20540, 30340, 26465, 30446, 12290),
    }

    text.append = function(self, str, hl, opts)
        if self.view and self.view.state and replacements[str] then
            str = replacements[str]
        elseif self.view and self.view.state and type(str) == "string" then
            if str:match("^%d+ plugins$") then
                str = str:gsub(" plugins$", " " .. zh(20010, 25554, 20214))
            elseif str == "avg time" then
                str = zh(24179, 22343, 32791, 38388)
            elseif str == "time" then
                str = zh(32791, 38388)
            elseif str == "total" then
                str = zh(24635, 25968)
            end
        end
        return old_append(self, str, hl, opts)
    end

    text._zh_append_patched = true
end

vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "VeryLazy",
    callback = patch_lazy_ui,
})
