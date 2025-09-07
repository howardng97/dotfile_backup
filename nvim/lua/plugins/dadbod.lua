return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "plsql" } },
      { "kristijanhusak/vim-dadbod-ui" },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_use_nerd_fonts = 1
      -- Mapping: Open DBUI
      vim.keymap.set("n", "<Leader>bb", ":DBUIToggle<CR>", { desc = "Open Dadbod UI", silent = true })
    end,
    ft = { "sql", "plsql" }, -- Chỉ load nếu mở file SQL hoặc PLSQL
  },
}
