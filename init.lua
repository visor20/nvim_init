vim.o.number = true --line numbers
vim.o.relativenumber = false
vim.o.expandtab = true -- expand \t into spaces
vim.o.smartindent = true
vim.o.tabstop = 2 --number of spaces for a tab
vim.o.shiftwidth = 2
vim.opt.termguicolors = true

vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n', '<Leader>w', ':w<CR>', { noremap = true, silent = true })

-- Bootstrap packer if it isn't installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Autocommand that reloads neovim whenever you save the init.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]]

-- plugins --
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer manages itself

    -- Plugin examples
    use {
	'nvim-treesitter/nvim-treesitter',
	run = ':TSUpdate'
	}
	
	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons',
		},
	}

	use {
  		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
  		requires = { 
			'nvim-lua/plenary.nvim',
		},
	}

  -- auto pair for {}, (), etc.
  use { 'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
          require('nvim-autopairs').setup {}
        end
      }

	-- nvim-cmp main plugin
	use { 'hrsh7th/nvim-cmp' }
	  
	-- nvim-cmp completion sources
	use { 'hrsh7th/cmp-buffer' }        -- Buffer completions
	use { 'hrsh7th/cmp-path' }          -- Path completions
	use { 'hrsh7th/cmp-nvim-lsp' }      -- LSP completions
	use { 'hrsh7th/cmp-nvim-lua' }      -- Lua API completions (useful for neovim config)
	use { 'saadparwaiz1/cmp_luasnip' }  -- Snippet completions

	-- Snippet engine (luasnip)
	use { 'L3MON4D3/LuaSnip' }          -- Snippet engine
	  
	-- LSP Support (if not already set up)
	use { 'neovim/nvim-lspconfig' }     -- LSP configuration

	use { 'catppuccin/nvim', as = 'catppuccin' } -- theme

	if packer_bootstrap then
		require('packer').sync()
	end
end)

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- or specify languages
  highlight = {
    enable = true,
  },
}

-- recommended settings from the nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

require('telescope').setup{
  defaults = {
    -- Default configuration for Telescope goes here:
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    prompt_position = "bottom",
    prompt_prefix = "> ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
    },
  },
}

-- Setup nvim-cmp for autocompletion
local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- Specify the snippet engine (luasnip in this case)
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
    ['<Tab>'] = cmp.mapping.select_next_item(),        -- Navigate to next item
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),      -- Navigate to previous item
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- LSP completions
    { name = 'luasnip' },    -- Snippet completions
    { name = 'buffer' },     -- Buffer completions
    { name = 'path' },       -- Path completions
  })
})

-- LSP setup for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- python (pyright)
require('lspconfig')['pyright'].setup {
  capabilities = capabilities,
}

-- c, c++ (clangd)
require('lspconfig').clangd.setup {
  capabilities = capabilities,
  cmd = {'clangd'},
}

-- JS - ts server
-- ... todo

-- Load and apply Catppuccin
require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha (Choose your favorite variant)
  transparent_background = false, -- Enable/disable transparent background
  term_colors = true, -- Enable terminal colors
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
    },
    lsp_trouble = true,
    cmp = true,
    gitsigns = true,
    telescope = true,
    nvimtree = {
      enabled = true,
      show_root = true,
      transparent_panel = false,
    },
    which_key = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = false,
    },
  }
})

-- Set the colorscheme to catppuccin
vim.cmd.colorscheme "catppuccin"

-- key bindings --
vim.api.nvim_set_keymap('n', '<leader>sf', ":lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sg', ":lua require('telescope.builtin').live_grep()<CR>", { noremap = true, silent = true })
