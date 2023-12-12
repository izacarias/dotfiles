" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:
" This is my personal .vimrc file. It is based in Steve Francia .vimrc file
" that can be found in http://spf13.com or https://github.com/spf13
"
" This file isn't a copy of the entire file. Instead, I've just picked up the
" parts that I am interested. 
"
" The plugins are also based on Stefe Francia collection of VIM plugins 
"
" Big thanks to Steve Francia for making spf13-vim available :)
"
" Basics {
    set nocompatible            " Must be first line
    set background=dark         " Assume a dark background
" }


" Setup Bundle support {
    "if isdirectory(expand("~/.vim/bundle/vundle/"))
    "    filetype off
    "    set rtp+=~/.vim/bundle/vundle
    "    call vundle#rc()

    "    " Bundles {
    "    Bundle 'altercation/vim-colors-solarized'
    "    " }
    "endif
" }

" General {
    
    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction

    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8
    
    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator
    
    set nobackup                        " Disable local backup files
    set showmode
" }

" Formatting {

    set nowrap                      " Do not wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
" }

" Vim UI {
    
    colorscheme solarized8_low      " Setting my prefered colorscheme
    
    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        "if !exists('g:override_spf13_bundles')
        "    set statusline+=%{fugitive#statusline()} " Git Hotness
        "endif
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif 
" }

" Key (re)Mappings {
    let mapleader = ','
    
    noremap <leader>bg :call ToggleBG()<CR>
    
    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_no_easyWindows = 1
    if !exists('g:spf13_no_easyWindows')
        map <C-J> <C-W>j<C-W>_
        map <C-K> <C-W>k<C-W>_
        map <C-L> <C-W>l<C-W>_
        map <C-H> <C-W>h<C-W>_
    endif

" }

" Plugins {
    " UndoTree {
        if isdirectory(expand("~/.vim/pack/plugins/start/undotree/"))
            nnoremap <Leader>u :UndotreeToggle<CR>
            " If undotree is opened, it is likely one wants to interact with it.
            let g:undotree_SetFocusWhenToggle=1
        endif
    " } 
" }
