for _, arg in ipairs(vim.v.argv) do
  if arg == "opendb" then
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.cmd("DBUIToggle")
      end,
    })
    return -- Không load alpha
  end
end
