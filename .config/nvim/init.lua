vim.cmd([[set clipboard+=unnamedplus]])

vim.opt.number = true
vim.opt.cursorline = false
vim.opt.signcolumn = "auto"
vim.opt.signcolumn = "yes:1"
vim.opt.wrap = false

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.mousescroll = "ver:1" -- Multiplier

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showtabline = 0

vim.cmd([[filetype on]])
vim.cmd([[filetype plugin on]])

vim.cmd([[set formatoptions-=o]]) -- Disable auto comment in normal mode
vim.cmd([[set formatoptions-=r]]) -- Disable auto comment in insert mode
vim.cmd([[set formatoptions-=c]]) -- Disable auto wrap comment

-- Search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true -- Highlight all matches. Use :noh to clear highlights

vim.opt.fillchars:append({ diff = "╱" })

-- For if buftype == nofile
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(ctx)
    if vim.bo[ctx.buf].buftype ~= "nofile" then return end

    if vim.bo[ctx.buf].filetype == "markdown" then
      vim.opt.conceallevel = 3
      vim.opt.concealcursor = "nvic" -- Conceal under all circumstances
    end
  end,
})

vim.opt.pumblend = 0 -- Popup-menu transparency

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

---@type LazyPluginSpec
local pathlib = {
  "pysan3/pathlib.nvim",
  tag = "v2.2.2",
}

---@type LazyPluginSpec
local utils_nvim = {
  "samsze0/utils.nvim",
  priority = 100,
  dir = os.getenv("NVIM_UTILS_NVIM_PATH"),
  config = function()
    -- Load theme once before loading other plugins (to prevent theme flickering)
    require("utils").setup({})
    require("theme").setup({})
    require("keymaps").setup({})
    require("nvim-dev").setup({})
  end,
  dependencies = {
    pathlib,
  },
}

---@type LazyPluginSpec
local nui = { -- Required by fzf
  "MunifTanjim/nui.nvim",
  commit = "61574ce6e60c815b0a0c4b5655b8486ba58089a1",
}

---@type LazyPluginSpec
local jumplist = {
  "samsze0/jumplist.nvim",
  dir = os.getenv("NVIM_JUMPLIST_NVIM_PATH"),
  config = function() require("jumplist").setup({}) end,
}

local ui_nvim = {
  "samsze0/ui.nvim",
  dir = os.getenv("NVIM_UI_NVIM_PATH"),
  config = function()
    -- :h statusline
    vim.g.qf_disable_statusline = 1 -- Disable built-in statusline in Quickfix window
    vim.opt.laststatus = 2 -- 3 = global; 2 = always ; 1 = at least 2 windows ; 0 = never

    -- :h tabbline
    vim.opt.showtabline = 1 -- 2 = always ; 1 = at least 2 tabs ; 0 = never

    require("ui").setup({})
    require("ui.statusline").register(require("ui.statusline.presets"))
    require("ui.tabline").register(require("ui.tabline.presets"))
  end,
  dependencies = {
    utils_nvim,
  },
}

---@type LazyPluginSpec
local tui = {
  "samsze0/tui.nvim",
  dir = os.getenv("NVIM_TUI_NVIM_PATH"),
  dependencies = {
    nui,
    utils_nvim,
  },
}

---@type LazyPluginSpec
local terminal_filetype = {
  "samsze0/terminal-filetype.nvim",
  dir = os.getenv("NVIM_TERMINAL_FILETYPE_NVIM_PATH"),
  config = function() require("terminal-filetype").setup({}) end,
}

---@type LazyPluginSpec
local notifier = {
  "samsze0/notifier.nvim",
  dir = os.getenv("NVIM_NOTIFIER_NVIM_PATH"),
  config = function() require("notifier").setup({}) end,
  dependencies = {
    utils_nvim,
  },
}

---@type LazyPluginSpec
local fzf = {
  "samsze0/fzf.nvim",
  dir = os.getenv("NVIM_FZF_NVIM_PATH"),
  config = function()
    require("fzf").setup({
      default_extra_args = {
        ["--scroll-off"] = "2",
      },
      ipc_client_type = 1,
      fzf_bin = "~/dev/fzf/bin/fzf",
    })
  end,
  dependencies = {
    nui,
    utils_nvim,
    jumplist,
    terminal_filetype,
    notifier,
    tui,
  },
}

---@type LazyPluginSpec
local websocket = {
  "samsze0/websocket.nvim",
  dir = os.getenv("NVIM_WEBSOCKET_NVIM_PATH"),
  config = function() require("websocket").setup({}) end,
  dependencies = {
    utils_nvim,
  },
}

---@type LazyPluginSpec
local treesitter = {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.9.1",
}

---@type LazyPluginSpec
local colorizer = {
  "norcalli/nvim-colorizer.lua",
  config = function() require("config.colorizer") end,
  commit = "a065833f35a3a7cc3ef137ac88b5381da2ba302e",
}

---@type LazyPluginSpec
local nvim_lint = {
  -- Linters interface that reports to vim.diagnostic
  "mfussenegger/nvim-lint",
  config = function() require("config.nvim-lint") end,
  commit = "1a3a8d047bc01f1760ae4a0f5e80f111ea222e67",
}

---@type LazyPluginSpec
local conform = {
  -- Formatters interface that calculates minimal diff
  "stevearc/conform.nvim",
  config = function() require("config.conform") end,
  tag = "v5.8.0",
}

---@type LazyPluginSpec
local cmp_nvim_lsp = {
  -- completion source for lsp
  "hrsh7th/cmp-nvim-lsp",
}

---@type LazyPluginSpec
local schemastore = {
  "b0o/schemastore.nvim",
}

---@type LazyPluginSpec
local jdtls = {
  "mfussenegger/nvim-jdtls",
}

---@type LazyPluginSpec
local workspace_diagnostics = {
  "artemave/workspace-diagnostics.nvim",
  config = function() require("workspace-diagnostics").setup({}) end,
}

---@type LazyPluginSpec
local lspconfig = {
  "neovim/nvim-lspconfig",
  config = function() require("config.lspconfig") end,
  tag = "v0.1.8",
  dependencies = {
    cmp_nvim_lsp,
    schemastore,
    jdtls,
    workspace_diagnostics,
  },
}

---@type LazyPluginSpec
local gitsigns = {
  -- Git status in sign column, git hunk preview/navigation, and line blame
  "lewis6991/gitsigns.nvim",
  config = function() require("config.gitsigns") end,
  tag = "v0.8.1",
}

---@type LazyPluginSpec
local comment = {
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup({ ---@diagnostic disable-line: missing-fields
      mappings = false,
    })
  end,
  tag = "v0.8.0",
}

---@type LazyPluginSpec
local cmp_path = {
  -- completion source for filesystem paths
  "hrsh7th/cmp-path",
}

---@type LazyPluginSpec
local cmp_cmdline = {
  -- completion source for vim command line
  "hrsh7th/cmp-cmdline",
}

---@type LazyPluginSpec
local cmp_buffer = {
  -- completion source for buffer words
  "hrsh7th/cmp-buffer",
}

---@type LazyPluginSpec
local cmp_git = {
  -- completion source for git
  "petertriho/cmp-git",
}

---@type LazyPluginSpec
local lspkind = {
  -- add vscode-codicons to popup menu
  "onsails/lspkind.nvim",
}

---@type LazyPluginSpec
local LuaSnip = {
  -- snippet
  "L3MON4D3/LuaSnip",
}

---@type LazyPluginSpec
local nvim_cmp = {
  "hrsh7th/nvim-cmp",
  config = function() require("config.nvim-cmp") end,
  dependencies = {
    cmp_nvim_lsp,
    cmp_path,
    cmp_cmdline,
    cmp_buffer,
    cmp_git,
    lspkind,
    LuaSnip,
  },
  commit = "5260e5e8ecadaf13e6b82cf867a909f54e15fd07",
}

---@type LazyPluginSpec
local treesitter_textobjs = {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = {
    treesitter,
  },
}

---@type LazyPluginSpec
local treesitter_playground = {
  "nvim-treesitter/playground",
  dependencies = {
    treesitter,
  },
}

---@type LazyPluginSpec
local dap = {
  "mfussenegger/nvim-dap",
  config = function() require("config.dap") end,
}

---@type LazyPluginSpec
local yazi = {
  "samsze0/yazi.nvim",
  dir = os.getenv("NVIM_YAZI_NVIM_PATH"),
  config = function()
    require("yazi").setup({
      keymaps = {
        open = "<f2>",
        hide = "<f2>",
        open_in_new_window = "<C-w>",
        open_in_new_tab = "<C-t>",
        reveal_current_file = "<f3>",
      },
    })
  end,
  dependencies = {
    utils_nvim,
    nui,
    jumplist,
    tui,
    terminal_filetype,
  },
}

---@type LazyPluginSpec
local peek = { -- Markdown preview
  "toppair/peek.nvim",
  event = { "VeryLazy" },
  build = "deno task --quiet build:fast",
  config = function() require("config.peek") end,
  commit = "5820d937d5414baea5f586dc2a3d912a74636e5b",
}

---@type LazyPluginSpec
local git_conflict = {
  "akinsho/git-conflict.nvim",
  config = function() require("config.git-conflict") end,
  tag = "v2.0.0",
}

require("lazy").setup({
  lspconfig,
  gitsigns,
  comment,
  nvim_cmp,
  nvim_lint,
  conform,
  colorizer,
  treesitter,
  utils_nvim,
  jumplist,
  ui_nvim,
  notifier,
  nui,
  -- treesitter_textobjs,
  -- treesitter_playground,
  -- dap,
  -- terminal_filetype,
  -- fzf,
  -- websocket,
  -- yazi,
  -- peek,
  -- git_conflict,
})
