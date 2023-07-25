return {
  { "nvim-tree/nvim-web-devicons" },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.cmd[[colorscheme gruvbox-material]]
    end
  }
}
