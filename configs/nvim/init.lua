-- ==========================================================================
-- NEOVIM MINIMAL CONFIGURATION
-- Focused on Python, Lua, and Bash
-- ==========================================================================

-- 1. CORE OPTIONS
vim.g.mapleader = " "              -- Set space as the leader key
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Use relative line numbers for easy jumping
vim.opt.expandtab = true           -- Convert tabs to spaces (PEP 8 standard for Python)
vim.opt.shiftwidth = 4             -- 4 spaces per indentation
vim.opt.tabstop = 4                -- 4 spaces per tab
vim.opt.wrap = false               -- Disable line wrapping
vim.opt.ignorecase = true          -- Ignore case when searching
vim.opt.smartcase = true           -- Match case if search contains a capital letter
vim.opt.termguicolors = true       -- Enable true color support
vim.opt.clipboard = "unnamedplus"  -- Sync with Linux system clipboard
vim.opt.undofile = true            -- Maintain undo history between sessions
vim.opt.splitbelow = true          -- Horizontal splits open below
vim.opt.splitright = true          -- Vertical splits open to the right

-- 2. BASIC KEYMAPS
local keymap = vim.keymap.set
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save File" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Neovim" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlights" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Error/Warning Message" })
-- Delete text without copying it to the clipboard
keymap({"n", "v"}, "<leader>d", "\"_d", { desc = "Delete without copying" })
keymap({"n", "v"}, "<leader>x", "\"_x", { desc = "Delete character without copying" })

-- Better window navigation (Ctrl + hjkl)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- 3. BOOTSTRAP PLUGIN MANAGER (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- 4. PLUGINS
require("lazy").setup({
    -- Clean UI Theme
    {
        "navarasu/onedark.nvim",
        config = function()
            vim.cmd.colorscheme("onedark")
        end,
    },

    -- Syntax Highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "bash", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Fuzzy Finder for Files and Text
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep (Search Text)" },
        },
    },

    -- Git Visuals (Gitsigns)
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                -- Clean vertical bars for added/changed lines
                signs = {
                    add          = { text = '┃' },
                    change       = { text = '┃' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                },
                -- Set up keybindings only for files tracked by Git
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Jump between changed chunks (hunks) of code
                    map('n', ']c', gs.next_hunk, { desc = "Next Git Hunk" })
                    map('n', '[c', gs.prev_hunk, { desc = "Previous Git Hunk" })

                    -- Quality of Life Actions
                    map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview Git Hunk (Diff)" })
                    map('n', '<leader>gr', gs.reset_hunk, { desc = "Reset/Revert Git Hunk" })
                    map('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = "Git Blame (Current Line)" })
                end
            })
        end
    },

    -- IntelliSense (LSP and Autocompletion)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",           -- Installs language servers seamlessly
            "williamboman/mason-lspconfig.nvim", -- Bridges mason with lspconfig
            "hrsh7th/nvim-cmp",                  -- Autocompletion engine
            "hrsh7th/cmp-nvim-lsp",              -- LSP source for cmp
            "L3MON4D3/LuaSnip",                  -- Snippet engine
        },
        config = function()
            -- 4a. Setup Mason to install language servers
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls", "bashls", "ruff" },
            })

            -- 4b. Setup Keybindings for LSP features
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts = { buffer = event.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Variable" }))
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
                end,
            })

            -- 4c. Setup the Language Servers
            -- 4c. Setup the Language Servers (Neovim 0.11+ Native API)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Pyright
            vim.lsp.config("pyright", { 
                capabilities = capabilities,
                settings = {
                    python = {
                        pythonPath = vim.fn.exepath("python")
                    }
                }
            })
            vim.lsp.enable("pyright")

            -- Ruff
            vim.lsp.config("ruff", { capabilities = capabilities })
            vim.lsp.enable("ruff")

            -- Bashls
            vim.lsp.config("bashls", { capabilities = capabilities })
            vim.lsp.enable("bashls")

            -- Lua_ls
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                    },
                },
            })
            vim.lsp.enable("lua_ls")

            -- 4d. Setup Autocompletion UI and behavior
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter confirms selection
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }),
            })
        end,
    },
})

-- 5. AUTO-COMMANDS
-- Automatically format and organize imports for Python files on save using Ruff
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        -- 1. Tell Ruff to silently organize imports
        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
        })
        
        -- 2. Format the rest of the code
        vim.lsp.buf.format({ async = false })
    end,
})
