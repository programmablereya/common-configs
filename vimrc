" link destination: $HOME/.vimrc

" Enable modern Vim features not compatible with Vi spec.
set nocompatible

" Enable mouse support.
set mouse=a

" Run Pathogen package manager
execute pathogen#infect()

" Set up vim-gfm-syntax
let g:gfm_syntax_emoji_conceal = 0

let g:coc_global_extensions = ['coc-tslint-plugin', 'coc-tsserver', 'coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-yank', 'coc-prettier']

" Enable file type based indent configuration and syntax highlighting.
" Note that when code is pasted via the terminal, vim by default does not detect
" that the code is pasted (as opposed to when using vim's paste mappings), which
" leads to incorrect indentation when indent mode is on.
" To work around this, use ":set paste" / ":set nopaste" to toggle paste mode.
" You can also use a plugin to:
" - enter insert mode with paste (https://github.com/tpope/vim-unimpaired)
" - auto-detect pasting (https://github.com/ConradIrwin/vim-bracketed-paste)
filetype plugin indent on
syntax on

let g:ale_linters = {
\   'javascript': ['standard'],
\}
let g:ale_fixers = {'javascript': ['standard']}
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1
let g:airline#extensions#ale#enabled = 1
hi ALEError ctermbg=DarkRed ctermfg=White
hi ALEWarning ctermbg=106 ctermfg=Black

let g:airline#extensions#tabline#enabled = 1
set modeline
set expandtab
set shiftwidth=2
set softtabstop=2
set laststatus=2
hi Statement ctermfg=3 guifg=#C4A000

set synmaxcol=1000
set foldmethod=syntax
let javaScript_Fold=1
set foldcolumn=1
set foldlevelstart=99
set conceallevel=0

au BufNewFile,BufRead *.ts setlocal filetype=typescript
au BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx
