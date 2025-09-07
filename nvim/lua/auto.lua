local last_line = nil

vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*",
  callback = function()
    local current_line = vim.api.nvim_win_get_cursor(0)[1] -- Lấy dòng hiện tại
    if current_line ~= last_line then
      last_line = current_line
      vim.cmd("normal! zz") -- Căn dòng hiện tại vào giữa màn hình
    end
  end,
})
