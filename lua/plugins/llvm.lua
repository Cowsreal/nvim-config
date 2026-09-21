-- LLVM IR (.ll) support
-- 1. Vim defaults .ll to the "lifelines" filetype; it's LLVM IR for us.
-- 2. Ensure the tree-sitter `llvm` parser is installed for highlighting.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "llvm" } },
    init = function()
      vim.filetype.add({
        extension = {
          ll = "llvm",
        },
      })
    end,
  },
}
