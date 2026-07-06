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
    lazy = false, -- ADDED: This strictly forces it to load before anything else
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
          theme = "auto", -- CHANGED: "auto" immediately inherits the active colorscheme
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

-- 7. Codeium (Free AI Autocomplete)
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Disable default tab if it conflicts, but usually it works out of the box
      vim.g.codeium_disable_bindings = 1
      
      -- Set your own keybindings
      -- Press Tab to accept the suggestion
      vim.keymap.set('i', '<Tab>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      -- Press Alt+] to cycle to the next suggestion
      vim.keymap.set('i', '<M-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
      -- Press Alt+[ to cycle to the previous suggestion
      vim.keymap.set('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
      -- Press Ctrl+x to dismiss a suggestion you don't want
      vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
    end
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

-- 9. Native LSP Config (Neovim 0.11+ standard)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Start the LSP servers using Neovim's native engine
      -- (Still requires pyright and clangd installed on your OS)
      vim.lsp.enable("pyright")
      vim.lsp.enable("clangd")
      
      -- Attach keymaps only when an LSP connects to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
      })
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
