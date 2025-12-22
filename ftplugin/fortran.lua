-- ftplugin/fortran.lua

-- Set 4 spaces for indentation
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Optional: Handle specific Fortran comments nicely
vim.opt_local.commentstring = "! %s"
