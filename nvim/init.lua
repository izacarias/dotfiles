-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Setting LaTeX to use latexmk
vim.g.vimtex_compiler_method = "latexmk"
