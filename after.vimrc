"https://github.com/zaiste/vimified
"curl -L https://raw.github.com/zaiste/vimified/master/install.sh | sh
colorscheme default

noremap <Up> <Up>
noremap <Down> <Down>
noremap <Left> <Left>
noremap <Right> <Right>

inoremap <Up> <Up>
inoremap <Down> <Down>
inoremap <Left> <Left>
inoremap <Right> <Right>

set foldmethod=indent
set foldlevel=20
"vsplit

noremap <C-w>e :SyntasticCheck<CR>
noremap <C-w>f :SyntasticToggleMode<CR>
noremap <F8> :SyntasticToggleMode<CR>

"vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
vnoremap // y/\V<C-R>"<CR>

" Pour la gestion du ^M dans les fichiers Windows
noremap <C-A-d> :%s/<C-V><C-M>//g<CR>gg
noremap <C-d> :ed++ff=dos<CR>
noremap <C-u> :ed++ff=unix<CR>
noremap <C-u> :ed++ff=unix<CR>

"noremap ,<M-t> :!ctags -R .<CR>

"set tags=tags;/
"set tags+=mestags.tags;
set tags=~/mytags

let g:ycm_server_keep_logfiles = 1

:let g:vimfiler_as_default_explorer = 1

nmap <S-tab> :VimFilerExplorer<cr>

