return {
    { "folke/lazy.nvim" },

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
            terminal_colors = true,
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
            inverse = true,
            contrast = "",
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        }
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "dart", "c", "lua", "vim", "vimdoc", "query",
                "markdown", "markdown_inline", "javascript",
                "typescript", "php", "css", "vue",
                "latex", "typst"
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            enable = true,
            max_lines = 0,
            min_window_height = 0,
            line_numbers = true,
            multiline_threshold = 20,
            trim_scope = 'outer',
            mode = 'cursor',
            separator = nil,
            zindex = 20,
            on_attach = nil,
        },
    },

    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
        init = function()
            vim.g.tmux_navigator_disable_netrw_workaround = 1
        end,
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
            "TmuxNavigatorProcessList",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

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

    { "echasnovski/mini.align", version = false },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring", opts = {} },
        },
        config = function()
            vim.g.skip_ts_context_commentstring_module = true
            require("Comment").setup({
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
            })
        end,
    },

    { "folke/snacks.nvim",      opts = { input = {}, picker = {} } },

    {
        "stevearc/conform.nvim",
        lazy = true,
        event = { "BufReadPre", "BufNewFile" },
    },

    {
        "akinsho/flutter-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("after.plugin.flutter-tools")()
        end,
        ft = { "dart", "flutter" },
    },

    {
        "nvim-mini/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            skip_ts = { "string" },
            skip_unbalanced = true,
            markdown = true,
        },
    },

    {
        "nickjvandyke/opencode.nvim",
        version = "*",
        dependencies = {
            {
                "folke/snacks.nvim",
                optional = true,
                opts = {
                    input = {},
                    picker = {
                        actions = {
                            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
                        },
                        win = {
                            input = {
                                keys = {
                                    ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                                },
                            },
                        },
                    },
                },
            },
        },
        keys = {
            {
                "<leader>oa",
                function() require("opencode").ask() end,
                desc = "Ask opencode",
                mode = "n",
            },
            {
                "<leader>os",
                function() require("opencode").ask("@this: ") end,
                desc = "Ask opencode about selection",
                mode = "v",
            }
        },
        config = function()
            vim.g.opencode_opts = {}
            vim.o.autoread = true

            vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
                { desc = "Ask opencode…" })
            vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
                { desc = "Execute opencode action…" })
            vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,
                { desc = "Toggle opencode" })

            vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
                { desc = "Add range to opencode", expr = true })
            vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
                { desc = "Add line to opencode", expr = true })

            vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
                { desc = "Scroll opencode up" })
            vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
                { desc = "Scroll opencode down" })
        end,
    },

    {
        "OXY2DEV/markview.nvim",
        lazy = false,
    },

    {
        "yanralapdy/kiro.nvim",
        version = "v0.2.0",
        lazy = false,
        dependencies = { "folke/snacks.nvim" },
        opts = {
            pane = nil,
            prefix = "look at ",
            features = {
                context = true,
                prompts = true,
                operator = true,
                commands = true,
                statusline = true,
                checkhealth = true,
                select = true,
            },
        },
        keys = {
            { "<leader>kf", function() require("kiro").send_file() end,      desc = "Kiro: send file" },
            { "<leader>ka", function() require("kiro").ask_selection() end,  desc = "Kiro: ask about selection", mode = "v" },
            { "<leader>ks", function() require("kiro").select() end,         desc = "Kiro: select action",       mode = "v" },
            { "<leader>kp", function() require("kiro").select_and_ask() end, desc = "Kiro: select prompt",       mode = "v" },
            {
                "gk",
                function()
                    vim.o.opfunc = "v:lua.require'kiro.operator'.opfunc"
                    return "g@"
                end,
                desc = "Kiro: send range",
                expr = true,
                silent = true
            },
            { "gkk", function() require("kiro.operator").send_line() end, desc = "Kiro: send line", silent = true },
        },
    },

    {
        -- ponytail: dir=local clone while iterating; switch to "yanralapdy/pi.nvim" once stable
        dir = vim.fn.expand("~/Code/pi.nvim"),
        name = "pi-nvim",
        lazy = false,
        cmd = { "PiAsk" },
        dependencies = { "folke/snacks.nvim" },
        opts = {},
    },
}
