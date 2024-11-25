vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Nvim Tree Key Mappings
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = true
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- QOL Configurations
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.mouse = "a"
vim.opt.autochdir = true
vim.opt.expandtab = true

-- QOL Mappings
vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', ';', ':', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>pa', [[:s/\\/\//g<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<Leader>1', [[:lua vim.lsp.buf.format({ async = true })<CR>]], { noremap = true, silent = true })
map('n', '<leader>e', ':NvimTreeToggle<CR>')
map('n', '<leader>ff', ':Telescope find_files<CR>')
map('n', '<leader>fg', ':Telescope live_grep<CR>')
map('n', '<leader>fb', ':Telescope buffers<CR>')
map('n', '<leader>fh', ':Telescope help_tags<CR>')

-- BEGIN VIM-PLUG -- 
vim.cmd([[
  call plug#begin('~/.local/share/nvim/plugged')

  Plug 'https://github.com/vim-airline/vim-airline'
  Plug 'https://github.com/vim-airline/vim-airline-themes'
  Plug 'https://github.com/ryanoasis/vim-devicons'
  Plug 'https://github.com/terrortylor/nvim-comment'
  Plug 'http://github.com/tpope/vim-surround'
  Plug 'https://github.com/catppuccin/nvim'

  call plug#end()
]])

-- Airline Config
vim.g['airline_section_x'] = ''
vim.g['airline_section_y'] = ''
vim.g['airline_section_z'] = '%p%%'
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = 'atomic'
vim.g.airline_extensions_whitespace_enabled = 0
vim.g.airline_symbols = { trailing = '' }

-- Buffer Mappings
vim.api.nvim_set_keymap('n', '<Leader><Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader><S-Tab>', ':bprev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>x', ':bd<CR>', { noremap = true, silent = true })

-- BEGIN PACKER --
require('packer').startup(function(use)
  -- LSP and completion
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use 'jose-elias-alvarez/null-ls.nvim'

  -- Syntax highlighting and code manipulation
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Fuzzy finder
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzy-native.nvim', requires = { 'nvim-telescope/telescope.nvim' } }

  -- File explorer
  use 'kyazdani42/nvim-tree.lua'
  use 'nvim-tree/nvim-web-devicons'

  -- Auto pairs
  use 'windwp/nvim-autopairs'

  -- bufferline!
  use 'akinsho/bufferline.nvim'
  use 'moll/vim-bbye'
end)

-- lspconfig
local lspconfig = require('lspconfig')
lspconfig.pyright.setup{}
lspconfig.jdtls.setup{}
lspconfig.clangd.setup{}
lspconfig.gopls.setup{}
lspconfig.ts_ls.setup{}
require'lspconfig'.bashls.setup{
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_dir = function(fname)
        return require'lspconfig'.util.root_pattern('.git')(fname) or
               require'lspconfig'.util.path.dirname(fname)
    end,
    settings = {
        bash = {
            shellcheck = {
                enable = true,  -- Enable ShellCheck diagnostics
            },
            bashIde = {
                enable = true,  -- Enable bash IDE features
            },
        },
    },
}

-- completion
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- For LuaSnip integration
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),        -- Scroll documentation up
    ['<C-f>'] = cmp.mapping.scroll_docs(4),         -- Scroll documentation down
    ['<C-Space>'] = cmp.mapping.complete(),          -- Trigger completion
    ['<C-e>'] = cmp.mapping.close(),                 -- Close completion menu
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm completion with Enter
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item() -- Select the next item
      else
        fallback()             -- Fallback to default Tab behavior
      end
    end, { "i", "s" }),          -- Use Tab in insert and select modes
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item() -- Select the previous item
      else
        fallback()             -- Fallback to default Shift+Tab behavior
      end
    end, { "i", "s" }),          -- Use Shift+Tab in insert and select modes
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },   -- Completion from LSP
    { name = 'luasnip' },    -- Snippet completion
  }, {
    { name = 'buffer' },     -- Completion from the buffer
  }),
})

-- telescope
local telescope = require('telescope')

telescope.setup {
    defaults = {
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        initial_mode = "insert",
        layout_strategy = "flex",
        layout_config = {
            horizontal = { mirror = false },
            vertical = { mirror = false },
        },
        sorting_strategy = "descending",
        file_ignore_patterns = { "node_modules", ".git/", ".cache/", "*.lock" },
        mappings = {
            i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<C-q>"] = "close",
            },
            n = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<C-q>"] = "close",
            },
        },
    },
    pickers = {
        find_files = {
            hidden = true,
            find_command = { "rg", "--hidden", "--files" },
        },
        live_grep = {
            additional_args = function(opts)
                return {"--hidden"}
            end,
        },
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
    },
}
telescope.load_extension('fzy_native')

-- Nvim Tree setup
require("nvim-tree").setup {
  -- General options
  disable_netrw = true,
  hijack_netrw = true,
  open_on_tab = false,
  hijack_cursor = false,
  update_cwd = false,
  diagnostics = {
      enable = true,
      icons = {
          hint = "🐝",
          info = "🐟",
          warning = "🐌",
          error = "🪲",
      }
  },

  -- File type --
  renderer = {
    highlight_opened_files = "name", -- Optional: Highlights the name of the opened files
    icons = {
      show = {
        file = true, -- Show file icons
        folder = true, -- Show folder icons
        folder_arrow = true, -- Show arrows for open/close folder
        git = true, -- Show git icons (if using git integration)
      },
    },
  },

  -- View options
  view = {
      width = 30,
      side = "left",
      adaptive_size = false, -- Use adaptive size instead of auto_resize
      preserve_window_proportions = false,
      number = false,
      relativenumber = false,
  }
}

-- Auto Pairs setup
require('nvim-autopairs').setup{}

-- null-ls
local null_ls = require('null-ls')
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.prettier.with {
            extra_args = { "--single-quote", "--tab-width", "4", "--use-tabs", "false" }
        },
    },
}

-- bufferline
require("bufferline").setup{
    options = {
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator_icon = '|',
        buffer_close_icon = 'X',
        modified_icon = '*',
        close_icon = 'X',
        left_trunc_marker = '<',
        right_trunc_marker = '>',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 21,
        diagnostics = false,
        offsets = {{ filetype = "NvimTree", text = "File Explorer", text_align = "center", separator = true }},
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        separator_style = "thin",
    }
}
