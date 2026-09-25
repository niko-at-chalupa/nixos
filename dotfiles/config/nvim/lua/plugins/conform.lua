return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- Lazy load on file open
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
      },
      -- Configure format on save
      format_on_save = {
        lsp_fallback = true, -- Fallback to LSP if StyLua isn't available
        timeout_ms = 500,
      },
    })

    -- Optional: Manual formatting keymap (Leader + f)
    vim.keymap.set({ "n", "v" }, "<leader>f", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { desc = "Format file or range" })
  end,
}

