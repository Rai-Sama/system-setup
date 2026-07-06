-- Set leader key to Space (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
  -- 1. Theme: Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          treesitter = true,
          native_lsp = { enabled = true },
          telescope = true,
          nvimtree = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 2. Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
      })
    end,
  },

  -- 3. Fuzzy finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    },
  },

  -- 4. Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "sql", "c", "cpp", "lua", "vim", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- 5. File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle Explorer" },
    },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { group_empty = true },
      })
    end,
  },

  -- 6. Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- 7. GitHub Copilot
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },

  -- 8. LeetCode plugin
  {
    "kawre/leetcode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "python3",
      storage = {
        home = vim.fn.expand("~/everything/learning/job_prep/dsa/leetcode_sols"),
      },
    },
  },

  -- NEW: 9. Native LSP Config (No extra package managers)
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- Requires pyright installed on your OS (e.g., pip install pyright)
      lspconfig.pyright.setup({})
      -- Requires clangd installed on your OS (e.g., sudo apt install clangd)
      lspconfig.clangd.setup({})
      
      -- Basic LSP keymaps
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover Documentation" })
    end,
  },

  -- NEW: 10. Indent guides (Crucial for Python)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },
})

-- General Neovim options
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation & Tabs
opt.tabstop = 4       -- Updated for standard Python/C++ spacing
opt.shiftwidth = 4    -- Updated for standard Python/C++ spacing
opt.expandtab = true
opt.smartindent = true

-- UI & Aesthetics
opt.termguicolors = true
opt.signcolumn = "yes" -- Prevents text shifting when errors appear
opt.cursorline = true  -- Highlights the current line
opt.scrolloff = 8      -- Keeps 8 lines visible above/below cursor when scrolling

-- Search & System
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true  -- Case-insensitive search
opt.smartcase = true   -- ...unless you type a capital letter
opt.updatetime = 250   -- Faster completion and responsiveness
