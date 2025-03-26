function SetColor(color)
    color = color or "catppuccin"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function SetIndent()
    local tab = 4
    if has_value({ "javascript", "vue", "typescript" }, vim.bo.filetype) then
        tab = 2
    end

    vim.opt.tabstop = tab
    vim.opt.softtabstop = tab
    vim.opt.shiftwidth = tab
    print(vim.bo.filetype, tab)
end

function SFT()
    if has_value({ 'lua', 'javascript' }, vim.bo.filetype) then
        print(true)
    else
        print(false)
    end
end

SetIndent()
SetColor()
