return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "claude", -- This effectively tells it "Stop looking for Copilot"
      claude = {
        endpoint = "https://api.anthropic.com",
        --        model = "claude-opus-4-5-20251101",
        model = "claude-sonnet-4-5-20250929",
        temperature = 0,
        max_tokens = 4096,
      },
    },
  },
}
