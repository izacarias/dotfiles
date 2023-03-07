" Disable compatibility with vi
set nocompatible

" Setting the colorscheme
colorscheme solarized8_low

" Set background color to dar for terminal and light for GUI
if has('gui_running')
    set background=light
else
    set background=dark
endif

" Controlling the tab behaviour
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Enable filetype detection
filetype on
" Enable plugins and enable plugins for the detected filetype
filetype plugin on
" Load and indent files for the detected filetype
filetype indent on
" Turn on syntax highlighting
syntax on

set autoindent
" set textwidth=80
" Disable local backup files
set nobackup
set showmode
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.flv,*.img,*.xlsx

" Turning vim into a WordProcessor
" Enable spellchecking
func! WordProcessorMode()
 setlocal textwidth=80
 setlocal smartindent
 setlocal spell spelllang=en_us
 setlocal noexpandtab
endfu

" Mappings and shortcuts
let mapleader = "\\"
nnoremap <leader>\ `` 
call togglebg#map("<F5>")
com! WP call WordProcessorMode()

" Configurations for markdown files
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" Specific configuration form YAML files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Specific configurations for vim-latex
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_FormatDependency_pdf = 'dvi,ps,pdf'
set iskeyword+=:

