local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true

vim.keymap.set({'n', 'v'}, 'g', function()
  if vim.v.count > 0 then
    -- If a number is provided before 'g', jump to that line using Neovim's 'gg'
    return 'gg'
  else
    -- Otherwise, return 'g' to wait for the next keystroke (like 'h' or 'l')
    return 'g'
  end
end, { expr = true, remap = true, desc = "Jump to line with [count]g" })

vim.keymap.set('n', 'i', 'a', { remap = true })
vim.keymap.set('v', 'i', 'a', { remap = true })

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
