set nocompatible

runtime! debian.vim

if has("syntax")
  syntax on
endif

set background=dark

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set mouse=a		" Enable mouse usage (all modes)

if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

colorscheme desert
filetype plugin indent on
filetype indent on
set t_Co=256
set number
set laststatus=2
set nohlsearch
set incsearch
set ignorecase
set ruler
set autoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab
set smarttab
set nowrap
