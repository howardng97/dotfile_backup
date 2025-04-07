return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup {
      ensure_installed = { "typescript", "javascript", "lua", "json", "html", "css", "bash", "yaml", "go", "rust", "sql" },
      sync_install = false,
      highlight = { enable = true, additional_vim_regex_highlighting = { "tailwind" }, },
      indent = { enable = true },
    }
  end
}
