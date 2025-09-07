return {
  "howardng97/goback.nvim",
  config = function()
    require("goback").setup({
      save_win = true,
      save_tab = true
    })
    vim.keymap.set("n", "<Leader>gz", ":GoBackLast<CR>", { noremap = true, silent = true })
  end,

}
