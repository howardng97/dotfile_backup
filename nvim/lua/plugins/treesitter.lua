return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {
        "typescript",
        "javascript",
        "lua",
        "json",
        "html",
        "css",
        "bash",
        "yaml",
        "go",
        "rust",
        "python",
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
