" Modeline and Notes {
" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={,} foldlevel=0 foldmethod=marker spell:

" This is MY vimrc file. I am trying to customize it according to my
" preferences and workflow. Feel free to use it, copy, fork or update it. 
"
" This file is heavely based in Steve Francia's vimrc setup available on
" GitHub on https://github.com/spf13/
"
" There are some ideas I borrowed from Steve Losh and its valuable guide
" "Lear VIMscript the Hard Way". Turns out it isn't so hard an I strongly
" recommend to take a look at his book at 
" https://learnvimscriptthehardway.stevelosh.com/
"
"   Licensed under the Apache License, Version 2.0 (the "License");
"   you may not use this file except in compliance with the License.
"   You may obtain a copy of the License at
"
"       http://www.apache.org/licenses/LICENSE-2.0
"
"   Unless required by applicable law or agreed to in writing, software
"   distributed under the License is distributed on an "AS IS" BASIS,
"   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
"   See the License for the specific language governing permissions and
"   limitations under the License.
"
" }

" Environment {
    " Basics {
        set nocompatible        " Must be first line
    " }
" }

" TODO: Move to an external file?
" Manage Plugins {
    filetype off                  " required
    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    Bundle 'scrooloose/nerdtree'
    Bundle 'altercation/vim-colors-solarized'
    Bundle 'spf13/vim-colors'
    Bundle 'tpope/vim-surround'
    Bundle 'scrooloose/nerdcommenter'

    Bundle 'ctrlpvim/ctrlp.vim'
    Bundle 'powerline/fonts'

    Bundle 'vim-airline/vim-airline'
    Bundle 'vim-airline/vim-airline-themes'

    call vundle#end()           " required
    filetype plugin indent on   " required
" }

" General {
    set background=dark         " I like the dark side of the Force :)
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax Highlight
    set mouse=a                 " Enable mouse when available
    set mousehide               " Hide mouse cursor when typing
    scriptencoding utf-8        " Use UTF-8 as default
    
    " Configure Clipboard {
    if has('clipboard')
        if has('unnamedplus') " Use + register for copy and paste when possible
            set clipboard=unnamed,unnamedplus
        else
            set clipboard=unnamed
        endif
    endif
    " }

    " Automatically switch to current file directory when a new buffer is
    " opened
    autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Setting up the directories {
        set backup
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif
    " }
"}

" Vim UI {
    if filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_contrast="normal"
        let g:solarized_visibility="normal"
        color solarized                 " Load a colorscheme
    endif

    set tabpagemax=15                   " Maximum of 15 pages im gVim
    set showmode                        " Display current mode in the satus line

    set cursorline                      "Highlight the line with the cursor

    highlight clear SignColumn          " SignColumn should match background
    highlight clear LineNr              " Current line number row will have same background color in relative mode

    if has('cmdline_info')
        set ruler                       " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                     " Show partial commands in status line and
                                        " select characters in visual mode
    endif


    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                        " Filename
        set statusline+=%w%h%m%r                    " Options
        
        " TODO: Add VimFugitive Plugin to show git status
        " set statusline+=%{fugitive#statusline()} " Git Hotness
        
        set statusline+=\ [%{&ff}/%Y]               " Filetype
        set statusline+=\ [%{getcwd()}]             " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%     " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

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

    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)

    " This is the place to customize the Formatting of specific languages
    " FileType Customization{
        autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
        autocmd FileType haskell,rust setlocal nospell
    " }
" }

" Key Remappings {
    let mapleader = ','             " Leader is comma, instead of default /

    " Edit and applu new vimrc configiration with
    " <leader>ev and <leader>sv> respectively
    nnoremap <leader>ev :vsplit $MYVIMRC<cr>
    nnoremap <leader>sv :source $MYVIMRC<cr>

    map <C-J> <C-W>j<C-W>_
    map <C-K> <C-W>k<C-W>_
    map <C-L> <C-W>l<C-W>_
    map <C-H> <C-W>h<C-W>_

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

        " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>


    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    "Stupid Shift key fix
    if has("user_commands")
        command! -bang -nargs=* -complete=file E e<bang> <args>
        command! -bang -nargs=* -complete=file W w<bang> <args>
        command! -bang -nargs=* -complete=file Wq wq<bang> <args>
        command! -bang -nargs=* -complete=file WQ wq<bang> <args>
        command! -bang Wa wa<bang>
        command! -bang WA wa<bang>
        command! -bang Q q<bang>
        command! -bang QA qa<bang>
        command! -bang Qa qa<bang>
    endif
" }
