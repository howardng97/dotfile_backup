return {
  {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy
  },
  {
  'stevearc/conform.nvim',
  opts = {},
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "gopls",
          "rust_analyzer",
          "denols",
          "sqls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local util = require("lspconfig/util")
      --local on_attach = lspconfig.on_attach
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.denols.setup({
        --on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        --on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern("package.json"),
        single_file_support = false,
        init_options = {
          preference = {
            disableSuggestions = true,
          }
        }
      })
      --lspconfig.rust_analyzer.setup({
      --  capabilities = capabilities,
      --  filetypes = { "rust" },
      --  root_dir = util.root_pattern("Cargo.toml"),
      --  settings = {
      --    ['rust_analyzer'] = {
      --      cargo = {
      --        allFeatures = true,
      --        cargo = { buildScripts = { enable = true } },
      --        procMacro = { enable = true },
      --      },
      --    }
      --  }
      --})
      lspconfig.gopls.setup({
        capabilities = capabilities,
        cmd = { "gopls" },
        root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        settings = {
          gopls = {
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
          },
        },
      })
      lspconfig.sqls.setup({
        cmd = { "sqls" },
        filetypes = { "sql" },
        settings = {
          sqls = {
          }
        }
      })
      vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})-- goto definition
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
}
