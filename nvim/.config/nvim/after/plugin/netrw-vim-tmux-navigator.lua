-- Override netrw's C-h and C-l with vim-tmux-navigator after netrw finishes setup
local function setup_netrw_maps(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    if vim.bo[buf].filetype ~= 'netrw' then return end
    vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { buffer = buf, silent = true, remap = false })
    vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { buffer = buf, silent = true, remap = false })
end

-- Apply to existing netrw buffers at startup (e.g. `nvim .`)
local function apply_to_existing()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        setup_netrw_maps(buf)
    end
end

if vim.defer_fn then
    vim.defer_fn(apply_to_existing, 100)
    vim.defer_fn(apply_to_existing, 300)
else
    vim.schedule(apply_to_existing)
end

-- Set up for future netrw buffers
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function(args)
        -- args.buf is the exact netrw buffer -- must capture it here, NOT
        -- call nvim_get_current_buf() inside the deferred function.
        local buf = args.buf and args.buf > 0 and args.buf or vim.api.nvim_get_current_buf()

        -- Set immediately so keys work right away
        setup_netrw_maps(buf)

        -- Retry after delays: netrw often sets its own buffer-local mappings
        -- slightly after FileType, so we stomp them back down.
        if vim.defer_fn then
            vim.defer_fn(function() setup_netrw_maps(buf) end, 100)
            vim.defer_fn(function() setup_netrw_maps(buf) end, 300)
        end
    end,
})
