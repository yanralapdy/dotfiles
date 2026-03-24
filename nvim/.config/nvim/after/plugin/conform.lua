local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        php = { "php" },
        json = { "jq" },
    },
    format_on_save = {
        lsp_fallback = false,
        async = false,
        timeout_ms = 1000,
    },
    notify_on_error = true,
    formatters = {
        php = {
            command = "php-cs-fixer",
            args = {
                "fix",
                "$FILENAME",
                "--config=/your/path/to/config/file/[filename].php",
                "--allow-risky=yes",
            },
            stdin = false,
        },
        -- Custom jq configuration
        jq = {
            -- --indent 4 for 4 spaces, or --tab for tabs
            args = { "--indent", "2", "." }, 
        },
    }
})
