call plug#begin()
" YCM requires ncurses5-compat-libs
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
Plug 'embear/vim-localvimrc'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'morhetz/gruvbox'
Plug 'neomake/neomake'
Plug 'tikhomirov/vim-glsl'
Plug 'lervag/vimtex'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neoinclude.vim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-clang', { 'do': ':UpdateRemotePlugins' }
call plug#end()

call deoplete#enable()
au InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
let g:deoplete#sources#clang#libclang_path="/usr/lib/libclang.so"
let g:deoplete#sources#clang#clang_header="/usr/lib/clang"

let g:localvimrc_whitelist=[
			\'/home/bassam/projects/inf8702/',
			\'/home/bassam/projects/opengl-tutorial/ogl-OpenGL-tutorial_0015_33/',
			\'/home/bassam/phd/sofa/']
let g:localvimrc_sandbox = 0

au FileType c,cpp map <buffer> <Leader>b :make!<CR>
au FileType c,cpp map <buffer> <Leader>r :make! run<CR>
au BufWritePost,BufEnter *.cpp,*.tex Neomake

au BufRead,BufNewFile *.scn set ft=xml

" Exit terminal mode with Esc
tnoremap <Esc> <C-\><C-n>

" Allow switching buffers without saving
set hidden
" %% as directory name on command line
"ca <expr> %% expand('%:p:h')

colorscheme gruvbox
set background=dark
set ts=4 sw=4

set ignorecase  " ignore case for lower-case searches
set smartcase   " but not if upper-case characters are present
set wrapscan    " wrap search at end of file
set nohls		" do not highlight search occurences
set gdefault    " substitute all matches in a line by default
set showmatch   " show matching brackets

"autcomplete common part, then cycle
"set wildmode=list:longest,full

" Underline the current line with dashes in normal mode
nnoremap <Leader>u yypVr
nmap <Leader>h <Esc>:call FormatHeader("=")<Left><Left>
nmap <Leader>t :NERDTreeToggle<CR>
"search and replace word under cursor
noremap <Leader>s :%s/\<<C-r><C-w>\>//<Left>

"Formatting functions {{{1
" Add leading and trailing "=" around a header, and comment line
"  (5* C-V + C-[) replaces <Esc> in a map since using <Esc> interrupts
" the exe.
" The following function will raise an error if "cms" is not defined:
"  nnoremap <Leader>h :exe "normal 0d$i" . split(&cms,"%s")[0] "" . &tw ."a=05la hp080ld$" <CR>
" Better version:
function! FormatHeader(fill)
    let cms_l = split(&cms,"%s")
    let cms_start = !empty(cms_l) ? cms_l[0] : "#"
    let cms_end = len(cms_l)>1 ? cms_l[1] : ""
    let width = &tw ? &tw : 100

    " zv: if we don't reopen the fold after "p", the next "d" might delete
    " the whole block.
    exe "normal 0Di".cms_start "\<Esc>".width."a".a:fill."\<Esc>".(len(cms_start)+4)."|a  \<Esc>hpzv".(width+1)."|D"
    if !empty(cms_end)
        exe "normal" len(cms_end)."hR" cms_end
    endif
endfunction

"Helper functions {{{1
func! g:GenClangInclude(dirs, root)
	return map(a:dirs, '"-I".a:root."/".v:val')
endfunc

func! g:SetClangFlags(flags)
	if !exists('g:neomake_cpp_clang_maker')
		let g:neomake_cpp_clang_maker = neomake#makers#ft#cpp#clang()
	endif
	let g:neomake_cpp_clang_maker["args"] = a:flags

	let g:deoplete#sources#clang#flags = a:flags
endfunc

" vim:ft=vim:fdm=marker
