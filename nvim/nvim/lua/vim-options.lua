vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
-- Show absolute line numbers
vim.o.number = true

vim.g.markdown_fenced_languages = {
	"ts=typescript",
}
-- Show relative line numbers
vim.opt.scrolloff = 12
vim.o.relativenumber = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.termguicolors = true
vim.g.mapleader = " " -- Set leader key to spaces
