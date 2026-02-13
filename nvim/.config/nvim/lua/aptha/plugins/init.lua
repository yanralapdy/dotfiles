return {
    -- Lazy can manage itself
    { "folke/lazy.nvim" },

    -- Telescope (fuzzy finder)
    {
        "nvim-telescope/telescope.nvim",
        version = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = true,
        opts = {
            terminal_colors = true, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            contrast = "",  -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        }
    },

    { 'folke/tokyonight.nvim', name = "tokyonight" },

    -- Catppuccin theme
    { "catppuccin/nvim",       name = "catppuccin" },

    -- Treesitter (syntax highlighting)
    -- {
    --     "nvim-treesitter/nvim-treesitter",
    --     build = ":TSUpdate",
    --     dependencies = { "nvim-treesitter/playground" }
    -- },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "dart",
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
                "javascript",
                "typescript",
                "php",
                "css",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },

    -- Treesitter context
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = function()
            return {
                enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
                max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end,
    },

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
        dependencies = {
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "neovim/nvim-lspconfig" },
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
        }
    },
    {
        "echasnovski/mini.align",
        version = false,
    },
    {
        "stevearc/conform.nvim",
        lazy = true,
        event = { "BufReadPre", "BufNewFile" },
    },
    {
        "akinsho/flutter-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",        -- optional
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = function()
            require("after.plugin.flutter-tools")() -- we’ll define this in `after/plugin`
        end,
        ft = { "dart", "flutter" },
    },
    {
        "nvim-mini/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            -- skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            -- skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "string" },
            -- skip autopair when next character is closing pair
            -- and there are more closing pairs than opening pairs
            skip_unbalanced = true,
            -- better deal with markdown code blocks
            markdown = true,
        },
    },
    -- {
    --     "nvim-java/nvim-java",
    --     dependencies = {
    --         "nvim-java/lua-async-await",
    --         "nvim-java/nvim-java-refactor",
    --         "nvim-java/nvim-java-core",
    --         "nvim-java/nvim-java-test",
    --         "nvim-java/nvim-java-dap",
    --         "neovim/nvim-lspconfig",
    --         "williamboman/mason.nvim",
    --     },
    --     config = function()
    --         require("mason").setup()
    --
    --         require("java").setup({
    --             jdk = {
    --                 auto_install = false, -- IMPORTANT: use SDKMAN Java
    --             },
    --         })
    --
    --         require("lspconfig").jdtls.setup({
    --             cmd = {
    --                 os.getenv("JAVA_HOME") .. "/bin/java",
    --             },
    --         })
    --     end,
    -- }
}
