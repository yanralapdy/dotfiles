-- Set number and relativenumber globally
vim.opt.number = true
vim.opt.relativenumber = true

-- Add node to PATH for LSP servers
local nvm_node_path = vim.fn.expand("$HOME/.nvm/versions/node/v20.20.1/bin")
if vim.fn.isdirectory(nvm_node_path) == 1 then
    vim.env.PATH = nvm_node_path .. ":" .. vim.env.PATH
end

-- Create an autocmd to enforce number and relativenumber in Netrw (:Vex)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.opt_local.number = true
        vim.opt_local.relativenumber = true
    end,
})

vim.opt.expandtab = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 20
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

