local zh = require("custom.lib").zh

local function translate_mason_text(text)
    local exact = {
        ["All"] = zh(20840, 37096),
        ["Installed"] = zh(24050, 23433, 35013),
        ["Installing"] = zh(23433, 35013, 20013),
        ["Queued"] = zh(38431, 38431, 20013),
        ["Failed"] = zh(22833, 36133),
        ["Available"] = zh(21487, 29992),
        ["No packages."] = zh(27809, 26377, 21487, 29992, 30340, 21253),
        ["Uninstalled registries"] = zh(26410, 23433, 35013, 30340, 27880, 20876, 28304),
        ["Registry installation failed with the following error:"] = zh(27880, 20876, 28304, 23433, 35013, 22833, 36133, 65292, 38169, 35823, 22914, 19979, 65306),
        ["executables"] = zh(21487, 25191, 34892, 25991, 20214),
        ["installed version"] = zh(24050, 23433, 35013, 29256, 26412),
        ["version"] = zh(29256, 26412),
        ["latest version"] = zh(26368, 26032, 29256, 26412),
        ["installed purl"] = zh(24050, 23433, 35013, 32) .. "purl",
        ["purl"] = "purl",
        ["homepage"] = zh(20027, 39029),
        ["languages"] = zh(35821, 35328),
        ["categories"] = zh(20998, 31867),
        ["Press "] = zh(25353, 19979, 32),
        [" to update "] = zh(32, 21487, 26356, 26032, 32),
        [" package "] = zh(32, 20010, 21253, 32),
        [" packages "] = zh(32, 20010, 21253, 32),
        [" (cancelling)"] = zh(32, 65288, 21462, 28040, 20013, 65289),
        ["鈻?Displaying full log"] = zh(9660, 32, 26174, 31034, 23436, 25972, 26085, 24535),
        ["LSP"] = "LSP",
        ["DAP"] = "DAP",
        ["Linter"] = "Linter",
        ["Formatter"] = "Formatter",
        ["Registries"] = zh(27880, 20876, 28304),
        ["Keyboard shortcuts"] = zh(24555, 38190, 24555, 25463),
        ["Problems installing packages"] = zh(23433, 35013, 21253, 26102, 36935, 21040, 38382, 39064),
        ["Problems with package functionality"] = zh(21253, 21151, 33021, 24322, 24120, 24322, 24120, 38382, 39064),
        ["How do I use installed packages?"] = zh(22914, 20309, 20351, 29992, 24050, 23433, 35013, 30340, 21253, 65311),
        ["Missing a package?"] = zh(32570, 23569, 26576, 20010, 21253, 65311),
        ["Mason log: "] = "Mason " .. zh(26085, 24535, 65306, 32),
        ["Packages are sourced from the following registries:"] = zh(21253, 26469, 28304, 20110, 20197, 19979, 27880, 20876, 28304, 65306),
        [" for package list"] = zh(32, 36820, 22238, 21253, 21015, 34920),
        [" for help"] = zh(32, 25171, 24320, 24110, 21161),
        ["Language Filter: "] = zh(35821, 35328, 31579, 36873, 65306, 32),
        ["Language Filter:"] = zh(35821, 35328, 31579, 36873, 65306),
        [" press <Esc> to clear"] = zh(32, 25353, 32, 60, 69, 115, 99, 62, 32, 28165, 38500),
        ["Make sure you meet the minimum requirements to install packages. For debugging, refer to:"] = zh(35831, 30830, 35748, 20320, 28385, 36275, 23433, 35013, 21253, 30340, 26368, 20302, 35201, 27714, 12290, 22914, 38656, 35843, 35797, 35831, 21442, 32771, 65306),
        ["Please refer to each package's own homepage for further assistance."] = zh(35831, 21442, 32771, 27599, 20010, 21253, 33258, 36523, 30340, 20027, 39029, 20197, 33719, 21462, 36827, 19968, 27493, 24110, 21161, 12290),
        ["Mason only makes packages available for use. It does not automatically integrate"] = "Mason " .. zh(21482, 36127, 36131, 35753, 21253, 21487, 29992, 65292, 19981, 20250, 33258, 21160, 38598, 25104),
        ["these into Neovim. You have multiple different options for using any given"] = zh(36825, 20123, 21040, 32, 78, 101, 111, 118, 105, 109, 12290, 23545, 20110, 20219, 24847, 19968, 20010),
        ["package, and you are free to pick and choose as you see fit."] = zh(21253, 65292, 20320, 37117, 21487, 20197, 26681, 25454, 33258, 24049, 30340, 26041, 24335, 33258, 30001, 36873, 25321, 12290),
        ["See "] = zh(35831, 21442, 32771, 32),
        [" for a recommendation."] = zh(32, 20197, 33719, 21462, 25512, 33616, 12290),
        ["Please consider contributing to mason.nvim:"] = zh(27426, 36814, 32771, 34385, 20026, 32) .. "mason.nvim" .. zh(32, 20570, 36129, 29486, 65306),
        ["Toggle help"] = zh(20999, 25442, 24110, 21161),
        ["Toggle package info"] = zh(20999, 25442, 21253, 20449, 24687),
        ["Toggle package installation log"] = zh(20999, 25442, 23433, 35013, 26085, 24535),
        ["Apply language filter"] = zh(24212, 29992, 35821, 35328, 31579, 36873),
        ["Install package"] = zh(23433, 35013, 21253),
        ["Uninstall package"] = zh(21368, 36733, 21253),
        ["Update package"] = zh(26356, 26032, 21253),
        ["Update all outdated packages"] = zh(26356, 26032, 25152, 26377, 36807, 26102, 21253),
        ["Check for new package version"] = zh(26816, 26597, 21253, 30340, 26032, 29256, 26412),
        ["Check for new versions (all packages)"] = zh(26816, 26597, 26032, 29256, 26412, 65288, 25152, 26377, 21253, 65289),
        ["Cancel installation of package"] = zh(21462, 28040, 21253, 23433, 35013),
        ["Close window"] = zh(20851, 38381, 31383, 21475),
        ["This is a read-only overview of the settings this server accepts. Note that some settings might not apply to neovim."] = zh(36825, 26159, 35813, 26381, 21153, 22120, 21487, 25509, 21463, 30340, 37197, 32622, 30340, 21482, 35835, 27010, 35272, 12290, 27880, 24847, 26576, 20123, 37197, 32622, 21487, 33021, 19981, 36866, 29992, 20110, 32, 110, 101, 111, 118, 105, 109, 12290),
    }

    if exact[text] then
        return exact[text]
    end

    local patterns = {
        { "^Deprecation message: ", zh(24323, 29992, 25552, 31034, 65306, 32) },
        { "^updating (%d+) registries $", zh(26356, 26032, 32, 27880, 20876, 28304, 32, "%1", 32) },
        { "^installing (%d+) registries $", zh(23433, 35013, 32, 27880, 20876, 28304, 32, "%1", 32) },
        { "^updating registry $", zh(26356, 26032, 27880, 20876, 28304, 32) },
        { "^installing registry $", zh(23433, 35013, 27880, 20876, 28304, 32) },
        { "^ %- (.+)$", " - %1" },
        { "^ %(press enter to collapse%)$", zh(32, 65288, 25353, 32, 69, 110, 116, 101, 114, 32, 25910, 36215, 65289) },
        { "^ %(press enter to expand%)$", zh(32, 65288, 25353, 32, 69, 110, 116, 101, 114, 32, 23637, 24320, 65289) },
        { "^ %(keywords: (.+)%)$", zh(32, 65288, 20851, 38190, 23383, 65306, 32) .. "%1" .. zh(65289) },
        { "^ %(search mode, press <Esc> to clear%)$", zh(32, 65288, 25628, 32034, 27169, 24335, 65292, 25353, 32, 60, 69, 115, 99, 62, 32, 28165, 38500, 65289) },
        { "^ press (.+) to apply filter$", zh(32, 25353, 32) .. "%1" .. zh(32, 24212, 29992, 31579, 36873) },
        { "^Please input a number$", zh(35831, 36755, 20837, 25968, 23383) },
        { "^This plugin requires `luarocks`%. Try one of the following:$", zh(35813, 25554, 20214, 20381, 36182, 32, 96, 108, 117, 97, 114, 111, 99, 107, 115, 96, 12290, 21487, 20197, 23581, 35797, 20197, 19979, 26041, 27861, 65306) },
    }

    for _, item in ipairs(patterns) do
        local pattern, replacement = item[1], item[2]
        if text:match(pattern) then
            return text:gsub(pattern, replacement)
        end
    end

    return text
end

local function patch_mason_ui()
    local ok_ui, ui = pcall(require, "mason-core.ui")
    if ok_ui and not ui._zh_patched then
        local old_hl_text_node = ui.HlTextNode
        local old_virtual_text_node = ui.VirtualTextNode

        ui.HlTextNode = function(lines_with_span_tuples)
            if type(lines_with_span_tuples) == "table" and lines_with_span_tuples[1] ~= nil then
                if type(lines_with_span_tuples[1]) == "string" then
                    lines_with_span_tuples = { { lines_with_span_tuples } }
                end
                for _, line in ipairs(lines_with_span_tuples) do
                    for _, span in ipairs(line) do
                        if type(span) == "table" and type(span[1]) == "string" then
                            span[1] = translate_mason_text(span[1])
                        end
                    end
                end
            end
            return old_hl_text_node(lines_with_span_tuples)
        end

        ui.VirtualTextNode = function(virt_text)
            if type(virt_text) == "table" then
                for _, span in ipairs(virt_text) do
                    if type(span) == "table" and type(span[1]) == "string" then
                        span[1] = translate_mason_text(span[1])
                    end
                end
            end
            return old_virtual_text_node(virt_text)
        end

        ui._zh_patched = true
    end
end

vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "VeryLazy",
    callback = patch_mason_ui,
})

return {
    patch = patch_mason_ui,
}
