return {
    -- Lazy can manage itself
    { "folke/lazy.nvim" },

    -- Telescope (fuzzy finder)
    {
        "nvim-telescope/telescope.nvim",
        version = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Catppuccin theme
    { "catppuccin/nvim", name = "catppuccin" },

    -- Treesitter (syntax highlighting)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = { "nvim-treesitter/playground" }
    },

    -- Treesitter context
    { "nvim-treesitter/nvim-treesitter-context" },

    -- Vim-tmux navigator
    { "christoomey/vim-tmux-navigator" },

    -- Undo history UI
    { "mbbill/undotree" },

    -- Git integration
    { "tpope/vim-fugitive" },

    -- Harpoon (file/bookmark manager)
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- LSP + Autocompletion
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "neovim/nvim-lspconfig" },
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
        }
    },
}

