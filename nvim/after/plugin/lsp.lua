local lsp_zero = require('lsp-zero')

--lsp_zero.on_attach(function(client, bufnr)
--	lsp_zero.default_keymaps({buffer = bufnr})
--end)

require('mason').setup({})
require('mason-lspconfig').setup({
	-- Replace the language servers listed here
	-- with the ones you want to install
	ensure_installed = {'volar', 'rust_analyzer', 'eslint', 'gopls', 'intelephense', 'lua_ls'},
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	}
})

  local cmp = require('cmp')
  local cmp_action = require('lsp-zero').cmp_action()
  local cmp_select = { behavior = cmp.SelectBehavior.Select }

  cmp.setup({
	  window = {
		  completion = cmp.config.window.bordered(),
		  documentation = cmp.config.window.bordered(),
	  },
	  mapping = cmp.mapping.preset.insert({
		  ['<C-Space>'] = cmp.mapping.complete(),
		  ['<C-f>'] = cmp_action.luasnip_jump_forward(),
		  ['<C-b>'] = cmp_action.luasnip_jump_backward(),
		  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
		  ['<C-d>'] = cmp.mapping.scroll_docs(4),
		  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
		  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		  ['<Enter>'] = cmp.mapping.confirm({ select = true }),
		  ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
		  ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
	  }),
	  snippet = {
		  expand = function(args)
			  require('luasnip').lsp_expand(args.body)
		  end,
	  },
	  sources = cmp.config.sources({
		  { name = 'nvim_lsp' },
	  }, {
		  {name = 'buffer'},
	  })
  })

lsp_zero.on_attach(function(_, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>ss", function() vim.lsp.buf.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.lsp.buf.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.lsp.buf.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp_zero.setup()
