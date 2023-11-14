local colors = require('theme').colors

require('base16-colorscheme').setup({
  base00 = colors.black,
  base01 = '#2c313c',
  base02 = '#3e4451',
  base03 = '#6c7891',
  base04 = '#565c64',
  base05 = '#abb2bf',
  base06 = '#9a9bb3',
  base07 = colors.white,

  base08 = colors.red,
  base09 = colors.yellow,
  base0A = colors.yellow,
  base0B = colors.blue,
  base0C = colors.blue,
  base0D = colors.blue,
  base0E = colors.blue,
  base0F = colors.blue,
})

local theme_colors = require('base16-colorscheme').colors

-- Override

vim.api.nvim_set_hl(0, "Search", {
  fg = nil;
  bg = theme_colors.base01;
})
vim.api.nvim_set_hl(0, "IncSearch", {
  fg = nil;
  bg = theme_colors.base06;
})
vim.api.nvim_set_hl(0, "Substitute", {
  fg = nil;
  bg = theme_colors.base02;
})

vim.api.nvim_set_hl(0, "MatchParen", {
  fg = nil;
  bg = theme_colors.base02;
})
