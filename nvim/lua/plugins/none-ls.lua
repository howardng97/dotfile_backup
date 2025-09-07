return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.completion.spell,
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "html", "css", "javascript", "typescript", "json", "yaml", "markdown", "ejs" },
        }),
        --:        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.gofumpt,
        null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.golines,
        null_ls.builtins.formatting.black.with({
          filetypes = { "python" },
          command = "black",
          args = { "--fast", "-" }, -- `--fast` skips safety checks for speed
          to_stdin = true,
        }),
        --	null_ls.builtins.formatting.ruff,
        --require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
        null_ls.builtins.formatting.dart_format.with({
          command = "dart", -- đảm bảo `dart` có trong $PATH
          args = { "format", "--output", "show", "--stdin-name", "$FILENAME", "-" },
          to_stdin = true,
          filetypes = { "dart" },
        }),
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
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
  end,
}
