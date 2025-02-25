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
  vim.lsp.buf.format()
end)

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>sc", [[:%s/\(<C-r><C-w>\|<C-r><C-w>\)/\=submatch(0) =~ '^\l.*' ? '<C-r><C-w>' : '<C-r><C-w>'/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>scl", [[:'<,'>s/\(<C-r><C-w>\|<C-r><C-w>\)/\=submatch(0) =~ '^\l.*' ? '<C-r><C-w>' : '<C-r><C-w>'/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

vim.keymap.set("n", "<leader>cfp", ":let @\" = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>cpo", ":let @\" = expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>cpf", ":let @\" = expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>cfn", ":let @\" = expand(\"%:t\")<CR>")
vim.keymap.set("n", "<leader>ccfp", ":let @+ = expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>ccpo", ":let @+ = expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>ccpf", ":let @+ = expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>ccfn", ":let @+ = expand(\"%:t\")<CR>")
