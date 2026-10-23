--local lsp = require('lsp-zero').preset({})
--
--lsp.on_attach(function(_, bufnr)
--    lsp.default_keymaps({ buffer = bufnr })
--end)
--
--lsp.setup()
--
--local dart_lsp = lsp.build_options('dartls', {})
--
--require('flutter-tools').setup({
--    flutter_path = vim.fn.expand('~/fvm/versions/3.32.1/bin/flutter'),
--    dart_path = vim.fn.expand('~/fvm/versions/3.32.1/bin/dart'),
--    lsp = {
--        capabilities = dart_lsp.capabilities
--    }
--})

local M = {}

M.setup = function()
  local lsp = require("lsp-zero").preset({})

  lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
  end)

  lsp.setup()

  local dart_opts = lsp.build_options("dartls", {})

  require("flutter-tools").setup({
    flutter_path = vim.fn.expand("~/fvm/versions/3.32.1/bin/flutter"), -- expands to the current user's home
    lsp = {
      capabilities = dart_opts.capabilities,
    },
  })
end

return M.setup
