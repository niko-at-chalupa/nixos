return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x", -- Using the recommended stable branch
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    cmd = "Telescope", -- Lazy-loads Telescope when you run the command
    keys = {
        {
            "<leader>ff",
            "<cmd>Telescope find_files<cr>",
            desc = "Find Files (Telescope)",
        },
        {
            "<leader>fg",
            "<cmd>Telescope live_grep<cr>",
            desc = "Live Grep (Telescope)",
        },
        {
            "<leader>fb",
            "<cmd>Telescope buffers<cr>",
            desc = "Find Buffers (Telescope)",
        },
        {
            "<leader>fh",
            "<cmd>Telescope help_tags<cr>",
            desc = "Help Tags (Telescope)",
        },
    },
    opts = {
        defaults = {
            prompt_prefix = "🔍 ",
            selection_caret = "❯ ",
            layout_strategy = "horizontal",
            layout_config = {
                prompt_position = "top",
            },
            sorting_strategy = "ascending",
        },
    },
}
