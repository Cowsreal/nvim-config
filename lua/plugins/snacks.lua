return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- Show hidden files by default
          ignored = true, -- Show git-ignored files (optional)
        },
      },
    },
  },
}
