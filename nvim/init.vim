set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
map <Leader>n <plug>NERDTreeTabsToggle<CR>
