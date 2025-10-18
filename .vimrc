" enter the current millenium
"
set nocompatible

" Set yourcolorscheme koehler
colorscheme koehler
" enable syntax and plugins (for netrw)
syntax enable
filetype plugin on

" Encoding
set encoding=utf-8


" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch


" Blink cursor on error instead of beeping (grr)
set visualbell


" Display all matching files when we tab complete
set wildmenu

" Set the autoindent

set autoindent

" NOW WE CAN:
" - Hit tab to :find by partial match
" - Use * to make it fuzzy

" THINGS TO CONSIDER:
" - :b lets you autocomplete any open buffer


" TAG JUMPING:
" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .

" NOW WE CAN:
" - Use ^] to jump to tag under cursor
" - Use g^] for ambiguous tags
" - Use ^t to jump back up the tag stack



" " Commenting blocks of code.
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
  autocmd FileType sh,ruby,python,yaml   let b:comment_leader = '# '
  autocmd FileType conf,fstab,bash,fish     let b:comment_leader = '# '
  autocmd FileType tex              let b:comment_leader = '% '
  autocmd FileType mail             let b:comment_leader = '> '
  autocmd FileType vim              let b:comment_leader = '" '
augroup END

noremap <silent> gc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> gu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>


" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Set Minimal Autocomplete
set cot=menu,menuone

ino <BS> <BS><C-r>=getline('.')[col('.')-4:col('.')-2]=~#'\k\k\k'?!pumvisible()?"\<lt>C-n>\<lt>C-p>":'':pumvisible()?"\<lt>C-y>":''<CR>
ino <CR> <C-r>=pumvisible()?"\<lt>C-y>":""<CR><CR>
ino <Tab> <C-r>=pumvisible()?"\<lt>C-n>":"\<lt>Tab>"<CR>
ino <S-Tab> <C-r>=pumvisible()?"\<lt>C-p>":"\<lt>S-Tab>"<CR>

augroup MinimalAutoComplete
    au!
    au InsertCharPre * if
    \ !pumvisible() &&
    \ !exists('s:complete') &&
    \ getline('.')[col('.')-3:col('.')-2].v:char =~# '\k\k\k' |
        \ let s:complete = 1 |
        \ noautocmd call feedkeys("\<C-n>\<C-p>", "nt") |
    \ endif
    au CompleteDone * if exists('s:complete') | unlet s:complete | endif
augroup END

" Just add this one line to make completion work with dots ansible.something
set iskeyword+=.

ino <C-f> <C-x><C-f>

 
 function! FixAnsibleYAML()
     if &ft != 'yaml' && &ft != 'yaml.ansible'
         return
     endif

     " Better single quoted strings with proper continuation
     syntax region yamlSingleQuotedString
           \ matchgroup=yamlStringDelimiter
           \ start=/'/
           \ skip=/''/
           \ end=/'/
           \ contains=yamlSingleEscape,@Spell
           \ containedin=ALLBUT,yamlComment
           \ keepend

     " Better double quoted strings
     syntax region yamlDoubleQuotedString
           \ matchgroup=yamlStringDelimiter
           \ start=/"/ 
           \ skip=/\\\\\|\\"/
           \ end=/"/
           \ contains=yamlEscape,@Spell
           \ containedin=ALLBUT,yamlComment
           \ keepend

     " Ansible-specific syntax enhancements
     syntax keyword yamlAnsibleKeyword 
           \ hosts vars tasks handlers roles 
           \ become become_user become_method
           \ gather_facts connection module_defaults
           \ next to include_tasks include_role
           \ containedin=yamlBlockMappingKey

     " Jinja2 template support within YAML
     syntax region yamlJinja2
           \ matchgroup=yamlJinja2Delimiter
           \ start=/{{{\?/ 
           \ end=/}}}\?/
           \ contains=@yamlJinja2Inner
           \ containedin=ALLBUT,yamlComment,yamlString

     " Fixed: Added proper delimiters for Jinja2 comments
     syntax region yamlJinja2Comment
           \ matchgroup=yamlJinja2CommentDelimiter
           \ start=/{#/ 
           \ end=/#}/
           \ containedin=ALLBUT,yamlComment,yamlString
 
     " Improved block mapping keys (performance fix)
     syntax match yamlBlockMappingKey /^\s*\zs\w\+\(\s*:\s*\|\s*:\s*$\)/
           \ containedin=ALL
           \ nextgroup=yamlFlowString,yamlString,yamlNumber,yamlBool

     " Performance optimizations
     setlocal synmaxcol=300
     setlocal re=1

     " Better indentation for Ansible
     setlocal shiftwidth=2
     setlocal softtabstop=2
     setlocal tabstop=2
     setlocal expandtab

     " Highlight groups
     highlight default link yamlAnsibleKeyword Statement
     highlight default link yamlJinja2 PreProc
     highlight default link yamlJinja2Delimiter Delimiter
     highlight default link yamlJinja2Comment Comment
     highlight default link yamlJinja2CommentDelimiter Comment
 endfunction

 " Auto-commands to apply the fix
 augroup AnsibleYAMLFix
     autocmd!
     autocmd FileType yaml call FixAnsibleYAML()
     autocmd BufRead,BufNewFile *.yml,*.yaml set filetype=yaml
 augroup END

 " Manual trigger if needed
 command! FixYAML call FixAnsibleYAML()


