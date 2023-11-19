-- :help <option> to get info (or :h)

vim.cmd [[set clipboard+=unnamedplus]] -- Use system clipboard

vim.opt.number = true
vim.opt.cursorline = false   -- Highlight current line
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = 'yes:1' -- Maximum 1 signs, fixed
vim.opt.wrap = false

-- :help fo-table
vim.cmd [[set formatoptions-=o]] -- Disable auto comment in normal mode
vim.cmd [[set formatoptions-=r]] -- Disable auto comment in insert mode
vim.cmd [[set formatoptions-=c]] -- Disable auto wrap comment

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0

vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true -- Highlight all matches. Pair with keymap :noh to clear highlights

vim.cmd [[set backupdir=~/.cache/nvim/backup]]
vim.cmd [[set directory=~/.cache/nvim/swap]]
vim.cmd [[set undodir=~/.cache/nvim/undo]]

vim.cmd [[filetype on]]
vim.cmd [[filetype plugin off]]

vim.opt.fillchars:append { diff = "╱" }

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('theme').setup({}) -- Setup once because some plugins might read existing highlight groups values

require("lazy").setup({
  {
    -- TODO: open file when swap file exists throw cryptic error
    'ibhagwan/fzf-lua',
    config = function()
      require('_fzflua')
    end,
  },
  {
    'github/copilot.vim',
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require("_lualine")
    end
  },
  {
    -- Show colors for color values e.g. hex
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('_colorizer')
    end
  },
  {
    -- Term within neovim
    'voldikss/vim-floaterm',
    enabled = true,
    config = function()
      vim.g.floaterm_width = 0.9
      vim.g.floaterm_height = 0.9
    end,
  },
  {
    -- Lf integration
    'ptzz/lf.vim',
    enabled = true,
    requires = {
      'voldikss/vim-floaterm'
    },
  },
  {
    'akinsho/toggleterm.nvim',
    enabled = false
  },
  {
    'lmburns/lf.nvim',
    enabled = false,
    requires = {
      'akinsho/toggleterm.nvim',
      config = function()
        require("toggleterm").setup()
      end
    },
    config = function()
      -- This feature will not work if the plugin is lazy-loaded
      vim.g.lf_netrw = 1

      require('lf').setup({
        escape_quit = false,
        border = "rounded",
      })

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = "LfTermEnter",
        callback = function(a)
          vim.api.nvim_buf_set_keymap(a.buf, "t", "q", "q", { nowait = true })
        end,
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neoconf.nvim',
      'hrsh7th/cmp-nvim-lsp'
    },
    config = function()
      require('_lspconfig')
    end
  },
  {
    -- Autoclosing brackets
    'windwp/nvim-autopairs',
    config = function()
      require('_autopairs')
    end
  },
  {
    -- Hop. Hijack search and f/t
    'folke/flash.nvim',
    config = function()
      require('_flash')
    end
  },
  {
    -- Configure lua-language-server for neovim config
    'folke/neodev.nvim',
    config = function()
      require("neodev").setup({})
    end
  },
  {
    -- Git status in sign column and git hunk preview/navigation and line blame
    'lewis6991/gitsigns.nvim',
    config = function()
      require('_gitsigns')
    end
  },
  {
    enabled = false,
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('_nvimtree')
    end
  },
  {
    -- Indentation markers
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup()
    end
  },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        mappings = false
      })
    end
  },
  {
    -- Project specific settings incl. LSP (w/ vscode interop)
    'folke/neoconf.nvim',
    enabled = false,
    config = function()
      require('_neoconf')
    end
  },
  {
    -- Highlight occurences of word current cursor
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure({})
    end
  },
  {
    -- Formatters interface that calculates minimal diff
    'stevearc/conform.nvim',
    config = function()
      require('_conform')
    end
  },
  {
    -- Linters interface that reports to vim.diagnostic, unlike ALE
    'mfussenegger/nvim-lint',
    config = function()
      require('_nvimlint')
    end
  },
  {
    -- Completion
    'hrsh7th/nvim-cmp',
    config = function()
      require('_nvimcmp')
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- nvim-cmp source for built-in language server client
      'hrsh7th/cmp-path',     -- nvim-cmp source for filesystem paths
      'hrsh7th/cmp-cmdline',  -- nvim-cmp source for vim command line
      'hrsh7th/cmp-buffer',   -- nvim-cmp source for buffer words
      'petertriho/cmp-git',   -- nvim-cmp source for git (commits, issues, mentions, etc.)
      'onsails/lspkind.nvim', -- add vscode-codicons to completion entries (function, class, etc.)
      'L3MON4D3/LuaSnip',     -- Snippet. For inserting text into editor
    }
  },
  {
    -- Scrollbar (show signs for git conflicts, diagnostics, search, etc.)
    'dstein64/nvim-scrollview',
    config = function()
      require('scrollview').setup({})
    end
  },
  {
    'sindrets/diffview.nvim',
    config = function()
      require('_diffview')
    end
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('_spectre')
    end
  },
  {
    -- Make and resurrect sessions with vim's built-in mksession
    'folke/persistence.nvim',
    config = function()
      require('persistence').setup({
        options = { "buffers", "curdir", "tabpages", "winsize" },
        pre_save = function()
        end,
        save_empty = true, -- whether to save if there are no open file buffers
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('_treesitter')
    end
  },
  {
    -- Act as tab bar
    'akinsho/bufferline.nvim',
    config = function()
      require('_bufferline')
    end
  },
})

require('keymaps')
require('winbar').setup() -- i.e. breadcrumbs
require('theme').setup({
  debug = {
    sources = {
      vim_fn_getcompletion = false,
      colon_highlights = false
    }
  }
})
