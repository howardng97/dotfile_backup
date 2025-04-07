return {
  "mbbill/undotree",
  config = function()
    vim.o.undofile = true
    vim.o.undodir = vim.fn.stdpath("config") .. "/undo"
    vim.fn.mkdir(vim.o.undodir, "p")
    vim.keymap.set('n', '<C-z>', vim.cmd.UndotreeToggle)
  end
}
