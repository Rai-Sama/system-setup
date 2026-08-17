-- ==========================================================================
-- NEOVIM MINIMAL CONFIGURATION
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
vim.opt.timeoutlen = 300           -- Decrease time to wait for a mapped sequence
vim.opt.mouse = "a"                -- Enable mouse support (lets you drag split borders!)

-- 2. BASIC KEYMAPS
local keymap = vim.keymap.set
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save File" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Neovim" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Highlights" })

-- Diagnostic Float keymap
keymap("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keymap("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Code Diagnostics" })

-- Delete text without copying it to the clipboard
keymap({"n", "v"}, "<leader>d", "\"_d", { desc = "Delete (No Copy)" })
keymap({"n", "v"}, "<leader>x", "\"_x", { desc = "Delete Char (No Copy)" })

-- Execute current file (Reuses ONLY the code runner terminal)
keymap("n", "<leader>r", function()
    local ft = vim.bo.filetype
    vim.cmd("write") -- Auto-save before running
    
    local cmd = ""
    if ft == "python" then
        cmd = "python3 %"
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

    -- Close ONLY the previous runner terminal, ignore background servers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].is_code_runner then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
    
    vim.cmd("15split | term " .. cmd)
    vim.cmd("setlocal nobuflisted")
    vim.b.is_code_runner = true -- Tag this specific buffer as the runner
end, { desc = "Run Code File" })

-- Format keybind moved to the "Code" group
keymap("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Code Format" })

-- Terminal Mode & Window Controls
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Toggle a persistent General Terminal (Prevents stacking)
keymap("n", "<leader>t", function()
    local term_buf = nil
    -- Find if our general terminal buffer already exists
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].is_general_term then
            term_buf = buf
            break
        end
    end

    if term_buf then
        -- Check if it is currently visible in a window
        local term_win = vim.fn.bufwinnr(term_buf)
        if term_win ~= -1 then
            vim.cmd(term_win .. "wincmd c") -- It's open, so close the split
        else
            -- It's hidden, so open a split and load the buffer
            vim.cmd("15split")
            vim.cmd("buffer " .. term_buf)
            vim.cmd("startinsert")
        end
    else
        -- It doesn't exist yet, so create it
        vim.cmd("15split | term")
        vim.cmd("setlocal nobuflisted")
        vim.b.is_general_term = true -- Tag this buffer as the general terminal
        vim.cmd("startinsert")
    end
end, { desc = "Toggle Terminal" })

-- Window navigation (Ctrl + hjkl)
keymap("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- Buffer Navigation (Close buffer moved to bd)
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

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
    -- Clean UI Theme (Tokyo Night)
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000, -- Ensure it loads first
        opts = {
            transparent = true, -- Allows Kitty's background to show through
            style = "night",    -- Options: 'storm', 'moon', 'night', or 'day'
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- File Explorer (NvimTree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = { group_empty = true },
                filters = { dotfiles = false },
            })
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
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
                    "c", "cpp", "cmake", "javascript", "html", "css", "json", "sql", "yaml" 
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
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Search Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Search Text" },
            { "<leader><space>", "<cmd>Telescope buffers<CR>", desc = "Search Buffers" },
        },
    },

    -- Markdown Rendering
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {},
        dependencies = { 
            "nvim-treesitter/nvim-treesitter", 
            "nvim-tree/nvim-web-devicons" 
        },
    },

    -- Inline Image Rendering (Works beautifully with Kitty)
    {
        "3rd/image.nvim",
        opts = {
            backend = "kitty",
            processor = "magick_cli", -- Uses system ImageMagick, avoids heavy Lua compilers
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true, -- Crucial: Downloads LeetCode's web URLs!
                    only_render_image_at_cursor = false,
                    filetypes = { "markdown" },
                },
            },
            max_width = nil,
            max_height = nil,
            max_width_window_percentage = 80, -- Prevents massive graphs from taking over
        },
    },

    -- Git Visuals (Gitsigns)
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = '┃' },
                    change       = { text = '┃' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    map('n', ']c', gs.next_hunk, { desc = "Next Git Hunk" })
                    map('n', '[c', gs.prev_hunk, { desc = "Previous Git Hunk" })
                    map('n', '<leader>gp', gs.preview_hunk, { desc = "Preview Hunk" })
                    map('n', '<leader>gr', gs.reset_hunk, { desc = "Reset Hunk" })
                    map('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = "Git Blame" })
                end
            })
        end
    },

    -- IntelliSense (LSP, Autocompletion, and Autopairs)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "windwp/nvim-autopairs", 
        },
        config = function()
            -- 4a. Setup Mason
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { 
                    "pyright", "lua_ls", "bashls", "ruff",
                    "clangd", "ts_ls", "html", "cssls", "jsonls", "marksman", "sqlls" 
                },
            })

            -- 4b. Restored LSP Keybindings (LspAttach)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
                    end

                    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
                    map("n", "gr", vim.lsp.buf.references, "Go to References")
                    map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
                    map("n", "K", vim.lsp.buf.hover, "Hover Docs")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>cr", vim.lsp.buf.rename, "Code Rename") -- Moved to cr to prevent conflict
                    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
                    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
                end,
            })

            -- 4c. Language Servers Configuration
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("pyright", {
                capabilities = capabilities,
            })
            vim.lsp.enable("pyright")
            
            vim.lsp.config("ruff", { capabilities = capabilities })
            vim.lsp.enable("ruff")

           vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            -- Stop the server from scanning massive hidden folders
                            ignoreDir = { ".git", "logs", "assets" },
                            -- Tell the server to load Neovim's native Lua APIs for better autocomplete
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
            vim.lsp.enable("lua_ls")

            local servers = { "bashls", "clangd", "ts_ls", "html", "cssls", "jsonls", "marksman", "sqlls" }
            for _, lsp in ipairs(servers) do
                vim.lsp.config(lsp, { capabilities = capabilities })
                vim.lsp.enable(lsp)
            end

            -- 4d. Setup Autopairs & Completion
            require("nvim-autopairs").setup({ check_ts = true })
            
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
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

            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
    
    -- Keybinding Popup Menu (Configured to label your prefixes cleanly)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                { "<leader>a", group = "AI Actions" },
                { "<leader>b", group = "Buffer" },
                { "<leader>c", group = "Code" },
                { "<leader>f", group = "Find" },
                { "<leader>g", group = "Git" },
            },
        },
    },

    -- Visual Tab Bar (Bufferline)
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp",
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                }
            })
        end,
    },

    -- AI Assistant (CodeCompanion with Gemini + Ollama explicit keymaps)
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local key_file = io.open(vim.fn.expand("~/.config/gemini.key"), "r")
            if key_file then
                vim.env.GEMINI_API_KEY = key_file:read("*a"):gsub("%s+", "")
                key_file:close()
            end

            require("codecompanion").setup({
                strategies = {
                    chat = { adapter = "gemini" },
                    inline = { adapter = "gemini" },
                },
                adapters = {
                    http = {
                        gemini = function()
                            return require("codecompanion.adapters").extend("gemini", {
                                schema = {
                                    model = {
                                        default = "gemini-3.6-flash",
                                    },
                                },
                            })
                        end,
                        ollama = function()
                            return require("codecompanion.adapters").extend("ollama", {
                                name = "ollama",
                                schema = {
                                    model = {
                                        default = "qwen2.5-coder:7b",
                                    },
                                },
                            })
                        end,
                    },
                },
            })
        end,
        keys = {
            { "<leader>ai", "<cmd>CodeCompanionActions<CR>", desc = "AI Actions" },
            { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle AI Chat" },
            { "<leader>ae", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "AI Edit/Explain Selection" },
        },
    },

})

-- 5. AUTO-COMMANDS
-- Python: Only organize imports on save (Do NOT aggressively format/wrap lines)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        -- Only organize imports silently
        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
        })
        
        -- Note: vim.lsp.buf.format() has been intentionally removed from here 
        -- to prevent Ruff from breaking long lines and function definitions.
    end,
})
