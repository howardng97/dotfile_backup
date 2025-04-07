return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    local event = "BufWritePre" -- or "BufWritePost"
    local async = event == "BufWritePost"
    null_ls.setup({
      sources = {
        null_ls.builtins.completion.spell,
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.golines,
        null_ls.builtins.formatting.rustfmt
        --require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
          })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function(args)
              require("conform").format({ bufnr = args.buf })
            end,
          })
        end
      end,
    })
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        -- Conform will run multiple formatters sequentially
        go = { "goimports", "gofmt" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = {
        pattern = "*.rs",
        timeout_ms = 500,
      },
    })
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
  end,
}
