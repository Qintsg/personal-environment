local M = {}

function M.zh(...)
    local chars = {}
    for _, codepoint in ipairs { ... } do
        chars[#chars + 1] = vim.fn.nr2char(codepoint)
    end
    return table.concat(chars)
end

function M.extend_unique(list, items)
    for _, item in ipairs(items) do
        if not vim.tbl_contains(list, item) then
            list[#list + 1] = item
        end
    end
end

function M.enable(server)
    Ice.lsp[server] = Ice.lsp[server] or {}
    Ice.lsp[server].enabled = true
end

function M.update_key_desc(plugin_name, lhs, desc)
    local plugin = Ice.plugins[plugin_name]
    if not plugin or type(plugin.keys) ~= "table" then
        return
    end

    for _, key in ipairs(plugin.keys) do
        if key[1] == lhs then
            key.desc = desc
            return
        end
    end
end

return M
