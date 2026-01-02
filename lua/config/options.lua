-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.tabstop = 3 -- Number of spaces tabs count for
opt.shiftwidth = 3 -- Size of an indent
opt.softtabstop = 3 -- Number of spaces in tab when editing
opt.expandtab = true -- Use spaces instead of tabs

opt.number = true -- Show line numbers
opt.relativenumber = false -- Disable relative line numbers

vim.filetype.add({
  extension = {
    fpp = "fortran",
  },
})

vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}
