require("basic")

-- Bootstrap Lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Futuristic theme Cyberdream with transparent background
  {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    opts = {
      transparent = true,
      italic_comments = true,
      hide_fillchars = true,
    },
  },

  -- AI Autocompletion (Codeium)
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },

  -- Completion extras
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },

  -- Icons for completion menu
  { "onsails/lspkind.nvim" },

  -- Linting and formatting via null-ls
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.diagnostics.eslint,
        }
      })
    end,
  },

  -- LSP and completion dependencies (existing)
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
})

-- Keymaps for LSP hover and signature help
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "cyberdream",
  callback = function()
    -- Function definitions → bold vibrant pink-red
    vim.api.nvim_set_hl(0, "@function",      { fg = "#FF2D20", bold = true })
    -- Function calls → italic slightly different pink-red
    vim.api.nvim_set_hl(0, "@function.call", { fg = "#FF2D20", bold = true, italic = true })
     vim.api.nvim_set_hl(0, "@parameter", { fg = "#E0DCCC" })
    vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#E0DCCC" })
    vim.api.nvim_set_hl(0, "@field", { fg = "#E0DCCC" })  -- sometimes class args
  end,
})

-- Apply Cyberdream theme
vim.cmd.colorscheme("cyberdream")

-- Treesitter settings
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "bash", "c", "cpp", "python", "javascript", "java" },
  highlight = { enable = true },
})

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright", "tsserver", "jdtls", "lua_ls" },
})

-- LSP config
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  clangd = {},
  pyright = {},
  tsserver = {},
  jdtls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } }
      }
    }
  },
}

for name, opts in pairs(servers) do
  opts.capabilities = capabilities
  lspconfig[name].setup(opts)
end

-- Completion setup
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  formatting = {
    format = require("lspkind").cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
    }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})


