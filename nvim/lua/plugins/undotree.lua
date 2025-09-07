return {
  "mbbill/undotree",
  config = function()
    vim.keymap.set('n', '<C-z>', vim.cmd.UndotreeToggle)
  end
}
