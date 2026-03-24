vim.g.mapleader = " "
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)

-- move one line content up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- paste without replacing yank buffer (paste and add paste buffer into a void)
vim.keymap.set("x", "<leader>p", "\"_dP")

-- yank to clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- delete without replacing yang buffer
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- map so that visual block change can be applied with C-c
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/scripts/tmux-sessionizer<CR>")

vim.keymap.set("n", "<leader>f", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>sc",
    [[:%s/\(<C-r><C-w>\|<C-r><C-w>\)/\=submatch(0) =~ '^\l.*' ? '<C-r><C-w>' : '<C-r><C-w>'/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>scl",
    [[:'<,'>s/\(<C-r><C-w>\|<C-r><C-w>\)/\=submatch(0) =~ '^\l.*' ? '<C-r><C-w>' : '<C-r><C-w>'/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- duplicate file command
vim.keymap.set("n", "<leader>cfp", ":let @\" = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>cpo", ":let @\" = expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>cpf", ":let @\" = expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>cfn", ":let @\" = expand(\"%:t\")<CR>")
vim.keymap.set("n", "<leader>ccfp", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>ccpo", ":let @+ = expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>ccpf", ":let @+ = expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>ccfn", ":let @+ = expand(\"%:t\")<CR>")

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
    } or {},
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
}


-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set("n", "<leader>co", function()
    local current = vim.api.nvim_get_current_buf()

    -- Harpoon v2
    local harpoon = require("harpoon")
    local harpoon_files = {}
    for _, item in ipairs(harpoon:list().items) do
        harpoon_files[item.value] = true
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
            local bt = vim.bo[buf].buftype
            local modified = vim.bo[buf].modified
            local name = vim.api.nvim_buf_get_name(buf)

            -- Only close real file buffers that are:
            -- - not modified
            -- - not harpoon-listed
            -- - not special buffers
            if bt == ""
                and name ~= ""
                and not modified
                and not harpoon_files[name]
            then
                vim.api.nvim_buf_delete(buf, { force = false })
            end
        end
    end
end, { desc = "Close buffers except current (Harpoon + unsaved aware)" })

