return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          -- Put your global fallback formatting rules here
          "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 3, TabWidth: 3, UseTab: Never, BreakBeforeBraces: Allman, AllowShortBlocksOnASingleLine: Never, AllowShortCaseLabelsOnASingleLine: false, AllowShortEnumsOnASingleLine: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: Never, AllowShortLambdasOnASingleLine: None, AllowShortLoopsOnASingleLine: false, SpaceBeforeParens: Custom, SpaceBeforeParensOptions: {AfterControlStatements: false, AfterForeachMacros: false, AfterIfMacros: false}}",
        },
      },
    },
  },
}
