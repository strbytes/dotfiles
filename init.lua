-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager
  -- use 'ludovicchabant/vim-gutentags' -- Automatic tags management
  
  use 'ggandor/lightspeed.nvim' -- Lightspeed quick movement
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'max397574/better-escape.nvim'  -- Better behavior for jk/kj escape mapping
  use 'windwp/nvim-autopairs' -- Automatic pair closing
  use 'windwp/nvim-ts-autotag' -- Automatic HTML tag closing
  
  use 'tpope/vim-fugitive' -- Git commands in nvim
  use 'tpope/vim-rhubarb' -- Fugitive-companion to interact with github
  use 'tpope/vim-surround' -- Easy bracket and tag manipulation
  use 'tpope/vim-sleuth' -- Auto-detect indentation
  use 'tpope/vim-repeat' -- Repeat for vim-surround
  
  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
  }

  use 'folke/which-key.nvim' -- Popup for key combinations
  use 'nvim-lualine/lualine.nvim' -- Fancier statusline
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  use 'rose-pine/neovim' -- Rose-Pine theme
  use 'xiyaowong/nvim-transparent' -- Enable transparency of background (show terminal background image)

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  -- UI feature that displays context in large functions/classes
  use 'nvim-treesitter/nvim-treesitter-context'
  -- Code outline window and quick navigation
  use 'stevearc/aerial.nvim'
  
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'williamboman/nvim-lsp-installer' -- Automated installer for LSPs
  use 'jose-elias-alvarez/null-ls.nvim' -- Allows using native LSP interface for other programs
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  use 'mattn/emmet-vim' -- Clunky emmet engine -- needs a formatter or else it's messy
  -- Sets comment string for languages embedded in files, e.g. CSS and JS in an HTML file
  use 'JoosepAlviste/nvim-ts-context-commentstring' 
  use 'norcalli/nvim-colorizer.lua' -- Display CSS colors in-editor
  -- use 'gpanders/nvim-parinfer' -- parinfer formatter for Lisps
end)

--Set tab defaults
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

require('rose-pine').setup({
    dark_variant = 'moon',
    })
require("transparent").setup({ enable = true })

--Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme rose-pine]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Setup file tree explorer
require("nvim-tree").setup()

--Set statusbar
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'rose-pine',
    component_separators = '|',
    section_separators = '',
  },
}

-- Set up which-key
require("which-key").setup()
local wk = require("which-key")

wk.register({
  ["<leader>"] = {
    t = { "<cmd>NvimTreeToggle<CR>", "File Tree Explorer"},
    s = {
      name = "Search",
      ["<space>"] = "Buffers",
      f = "Files",
      b = "Buffer fuzzy find",
      h = "Help",
      t = "Tags",
      d = "grep string",
      p = "Live grep",
      o = "Tags - Current buffer only",
      ["?"] = "Recent files",
    },
  g = {
    name = "Git",
    s = "Stage hunk",
    u = "Undo stage hunk",
    r = "Reset hunk",
    p = "Preview hunk",
    S = "Stage buffer",
    R = "Reset buffer",
    b = "Blame line",
    g = "Git Status",
    c = {
      c = "Git Commit",
      a = "Git Commit --amend"
    },
    d = {
      name = "Git Diff",
      d = "git diff",
      c = "git diff --cached"
    },
  },
  a = "Code outline window"
  },
})

--Setup quick escape mappings
require("better_escape").setup {
      mapping = {"jk", "kj", "JK", "KJ"},
      clear_empty_lines = true
}

--Enable Comment.nvim
require('Comment').setup{
  pre_hook = function(ctx)
    local U = require 'Comment.utils'

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require('ts_context_commentstring.utils').get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require('ts_context_commentstring.utils').get_visual_start_location()
    end

    return require('ts_context_commentstring.internal').calculate_commentstring {
      key = ctx.ctype == U.ctype.line and '__default' or '__multiline',
      location = location,
    }
  end,
}

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Indent blankline
require('indent_blankline').setup {
  char = '???',
  show_trailing_blankline_indent = false,
}

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '???' },
    changedelete = { text = '~' },
  },
  
on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']g', function()
      if vim.wo.diff then return ']g' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[g', function()
      if vim.wo.diff then return '[g' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>gs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>gr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>gS', gs.stage_buffer)
    map('n', '<leader>gu', gs.undo_stage_hunk)
    map('n', '<leader>gR', gs.reset_buffer)
    map('n', '<leader>gp', gs.preview_hunk)
    map('n', '<leader>gb', function() gs.blame_line{full=true} end)
    -- map('n', '<leader>tb', gs.toggle_current_line_blame)
    -- map('n', '<leader>gd', gs.diffthis)
    -- map('n', '<leader>gD', function() gs.diffthis('~') end)
    -- map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    -- Mappings for Fugitive
    -- from https://www.reddit.com/r/neovim/comments/v31ft4/comment/iavqkcn/
    map('n', '<leader>gg', ':Git status<CR>')
    map('n', '<leader>gcc', ':Git commit<CR>')
    map('n', '<leader>gca', ':Git commit --amend<CR>')
    map('n', '<leader>gdd', ':Git diff<CR><C-w>L')
    map('n', '<leader>gdc', ':Git diff --cached<CR><C-w>L')
  end
}

-- Telescope
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native
require('telescope').load_extension 'fzf'

--Add leader shortcuts
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<leader>sf', function()
  require('telescope.builtin').find_files { previewer = false }
end)
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>so', function()
  require('telescope.builtin').tags { only_current_buffer = true }
end)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = false, -- was not working with Python
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
  context_commentstring = {
    enable = true,
    -- enable_autocmd = false,
  },
  autotag = {
    enable = true,
    filetypes = { "html", "htmldjango", "xml" },
  }
}

require'treesitter-context'.setup{}

require("aerial").setup({
  manage_folds = true,
  -- link_folds_to_tree = true,
  -- link_tree_to_folds = true,
  on_attach = function(bufnr)
    -- Toggle the aerial window with <leader>a
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>a', '<cmd>AerialToggle!<CR>', {})
    -- Jump forwards/backwards with '{' and '}'
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '(', '<cmd>AerialPrev<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ')', '<cmd>AerialNext<CR>', {})
    -- Jump up the tree with '[[' or ']]'
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNextUp<CR>', {})
  end
})

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- LSP settings
require("nvim-lsp-installer").setup {}
local lspconfig = require 'lspconfig'

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable the following language servers
local servers = { 'html', 'cssls', 'tsserver', 'pyright'}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- null-ls setup
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
  -- Specify null-ls sources
  sources = {
    null_ls.builtins.diagnostics.eslint, -- eslint or eslint_d
    null_ls.builtins.code_actions.eslint, -- eslint or eslint_d
    null_ls.builtins.formatting.prettierd, -- prettier, eslint, eslint_d, or prettierd
    null_ls.builtins.formatting.black
  },
  
  -- lspconfig on-attach moved into null-ls setup to allow for autoformat on save
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-i>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      vim.inspect(vim.lsp.buf.list_workspace_folders())
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
    vim.api.nvim_create_user_command("Format", vim.lsp.buf.format, {})
    
    -- autoformat on save
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})

-- tells native LSP to default to null-ls for formatting
local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Set up autopairs and settings to make it play nice with CMP for new line splitting of pairs
require('nvim-autopairs').setup{
  enable_check_bracket_line = false
}
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

-- Set up colorizer
require('colorizer').setup()

-- ??? this was in the kickstarter.nvim file already commented out
-- vim: ts=2 sts=2 sw=2 et

-- Personal keymaps
vim.keymap.set('n', '\\w', ':set wrap!<CR>') -- Toggle word wrap
-- Safe paste from clipboard 
vim.keymap.set({'n'}, '\\p', ':set paste<CR>"*p:set nopaste!<CR>')
vim.keymap.set({'i'}, '\\p', '<Esc>:set paste<CR>"*p:set nopaste!<CR>')
vim.keymap.set({'n'}, '\\\\p', ':set paste<CR>"+p:set nopaste!<CR>')
vim.keymap.set({'i'}, '\\\\p', '<Esc>:set paste<CR>"+p:set nopaste!<CR>')
vim.keymap.set('n', 'vv', '^v$') -- Select text of line only
vim.keymap.set('i', ';;', '<ESC>A;<ESC>')
vim.keymap.set('i', '::', '<ESC>A:<ESC>')

-- Yank to clipboard
vim.keymap.set({'n', 'v'}, '\\y', '\"*y')
vim.keymap.set({'n', 'v'}, '\\\\y', '\"+y')

-- Quick move between windows
vim.keymap.set('n', '<C-h>', '<C-W>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Quick move windows
vim.keymap.set('n', '<A-h>', '<C-W>H')
vim.keymap.set('n', '<A-j>', '<C-w>J')
vim.keymap.set('n', '<A-k>', '<C-w>K')
vim.keymap.set('n', '<A-l>', '<C-w>L')
