vim.o.number=true
vim.o.wrap=false
vim.o.autoindent=true
vim.o.tabstop=4
vim.o.shiftwidth=4
vim.o.expandtab=true
vim.o.termguicolors=true

vim.g.mapleader=' '

require'plugins'
require'keys'
require'config'

vim.g.tokyonight_style='storm'
vim.cmd[[colorscheme tokyonight]]
