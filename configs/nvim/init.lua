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
vim.opt.timeout = true
vim.opt.timeoutlen = 300   -- Decrease time to wait for a mapped sequence

-- 2. BASIC KEYMAPS
local keymap = vim.keymap.set
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save File" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Neovim" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlights" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Error/Warning Message" })

-- Delete text without copying it to the clipboard
keymap({"n", "v"}, "<leader>d", "\"_d", { desc = "Delete without copying" })
keymap({"n", "v"}, "<leader>x", "\"_x", { desc = "Delete character without copying" })

-- Execute the current file based on its language
keymap("n", "<leader>r", function()
    local ft = vim.bo.filetype
    vim.cmd("write") -- Auto-save before running
    
    local cmd = ""
    if ft == "python" then
        cmd = "python %"
    elseif ft == "sh" then
        cmd = "bash %"
    elseif ft == "lua" then
        cmd = "lua %"
    elseif ft == "javascript" then
        cmd = "node %"
    elseif ft == "c" then
        cmd = "gcc % -o /tmp/c_out && /tmp/c_out"
    elseif ft == "cpp" then
        cmd = "g++ % -o /tmp/cpp_out && /tmp/cpp_out"
    else
        print("No runner configured for filetype: " .. ft)
        return
    end
    
    vim.cmd("15split | term " .. cmd)
    vim.cmd("setlocal nobuflisted")
end, { desc = "Run Current File" })

-- Add a universal format keybind for languages other than Python
keymap("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format Document" })

-- Easily exit terminal mode with Escape (instead of the default Ctrl+\ Ctrl+n)
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Open a built-in terminal at the bottom of the screen
keymap("n", "<leader>t", "<cmd>15split | term<CR>", { desc = "Open Terminal Split" })

-- Better window navigation (Ctrl + hjkl)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- Buffer Navigation
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })       -- Shift + L
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })   -- Shift + H
keymap("n", "<leader>c", "<cmd>bdelete<CR>", { desc = "Close current buffer" }) -- Space + c

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
                ensure_installed = { 
                    "python", "lua", "bash", "markdown", "markdown_inline",
                    "c", "cpp", "javascript", "html", "css", "json", "sql", "yaml" 
                },
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
            { "<leader><space>", "<cmd>Telescope buffers<CR>", desc = "Find Open Buffers" },
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
                ensure_installed = { 
                    "pyright", "lua_ls", "bashls", "ruff",
                    "clangd",     -- C/C++
                    "ts_ls",      -- JavaScript / TypeScript
                    "html",       -- HTML
                    "cssls",      -- CSS
                    "jsonls",     -- JSON
                    "marksman",   -- Markdown
                    "sqlls"       -- SQL
                },
            })

            -- 4b. Setup Keybindings for LSP features
            -- ... [Keep your existing 4b block exactly as it is] ...

            -- 4c. Setup the Language Servers (Neovim 0.11+ Native API)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Python (Pyright & Ruff)
            vim.lsp.config("pyright", { 
                capabilities = capabilities,
                settings = { python = { pythonPath = vim.fn.exepath("python") } }
            })
            vim.lsp.enable("pyright")
            
            vim.lsp.config("ruff", { capabilities = capabilities })
            vim.lsp.enable("ruff")

            -- Lua
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })
            vim.lsp.enable("lua_ls")

            -- General Servers (No special settings required)
            local servers = { "bashls", "clangd", "ts_ls", "html", "cssls", "jsonls", "marksman", "sqlls" }
            for _, lsp in ipairs(servers) do
                vim.lsp.config(lsp, { capabilities = capabilities })
                vim.lsp.enable(lsp)
            end

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
                    { name = "buffer" },
                    { name = "path" }
                }),
            })
            -- Automatically add parentheses after selecting a function or method
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
    
    -- Keybinding Popup Menu
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- Leave empty to use the excellent default settings
        },
    },

    -- Visual Tab Bar (Bufferline)
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons", -- Requires your Nerd Font
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp", -- Shows error icons right in the tab!
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                }
            })
        end,
    },

    -- Auto-close brackets and quotes
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true, -- Use treesitter to check if a pair should be auto-closed
            })
        end,
    },

    -- Cloud-Based Open Source AI (CodeCompanion + OpenRouter)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("codecompanion").setup({
                strategies = {
                    chat = { adapter = "openrouter" },
                    inline = { adapter = "openrouter" },
                },
                adapters = {
                    openrouter = function()
                        return require("codecompanion.adapters").extend("openai_compatible", {
                            env = {
                                url = "https://openrouter.ai/api",
                                api_key = "OPENROUTER_API_KEY",
                                chat_url = "/v1/chat/completions",
                            },
                            name = "OpenRouter",
                            schema = {
                                model = {
                                    default = "qwen/qwen-2.5-coder-32b-instruct:free",
                                },
                                -- Add this block to limit the token request
                                max_tokens = {
                                    default = 8000,
                                },
                            },
                        })
                    end,
                },
            })
        end,
        keys = {
            { "<leader>ai", "<cmd>CodeCompanionActions<CR>", desc = "AI Actions Menu" },
            { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle AI Chat Window" },
            { "<leader>ae", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "Explain/Refactor Selection" },
        },
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




