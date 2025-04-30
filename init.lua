-- Disable netrw (required by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Basic QoL options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.autochdir = true
vim.cmd("colorscheme desert")

-- Leader key
vim.g.mapleader = " "

-- Keymap helper
local function map(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- Basic mappings
map('n', ';', ':')
map('v', ';', ':')
map('n', '<leader>e', ':NvimTreeToggle<CR>')
map('n', '<leader>ff', ':Telescope find_files<CR>')
map('n', '<leader>fg', ':Telescope live_grep<CR>')
map('n', '<leader>fb', ':Telescope buffers<CR>')

-- Airline config
vim.g.airline_powerline_fonts = 0
vim.g.airline_symbols = {
  branch = 'b',       -- git branch symbol
  readonly = 'r',     -- readonly symbol
  linenr = 'L',       -- line number symbol
  maxlinenr = 'M',    -- max lines symbol
  dirty = '*',        -- unsaved changes
}
vim.g.airline_theme = 'alduin'

-- Packer plugin manager
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- UI
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'kyazdani42/nvim-tree.lua'

  -- Fuzzy Finder
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
end)

-- Nvim Tree setup
require("nvim-tree").setup {
  renderer = {
    icons = {
      webdev_colors = false,
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
      },
      glyphs = {
        default = "-",           -- file icon
        symlink = "~",           -- symlink icon
        folder = {
          default = ">",         -- closed folder
          open = "v",            -- open folder
          empty = ">",           -- empty folder
          empty_open = "v",      -- opened empty folder
          symlink = "~",         -- symlinked folder
        },
      },
    },
  }
}

-- Telescope basic setup
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" },
  }
}
