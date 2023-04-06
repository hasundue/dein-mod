" A directory where hook files are stored
let g:dein#mod#hook_dir = get(g:, 'dein#mod#hook_dir', '')

" A regexp for the beginning of a comment
let g:dein#mod#hook_comment_regexp = get(g:, 'dein#mod#hook_type_regexp',
  \ '^\("\|--\)')

" A regexp for a hook type
let g:dein#mod#hook_type_regexp = get(g:, 'dein#mod#hook_type_regexp',
  \ '\(hook_\w\+\|lua_\w\+\|ftplugin\[".\+"\]\)')

" A regexp for the start of a block
let g:dein#mod#hook_start_regexp = get(g:, 'dein#mod#hook_start_regexp',
  \ g:dein#mod#hook_comment_regexp . '\s\+\zs' . g:dein#mod#hook_type_regexp . '\ze\s\+{')

" A regexp for the end of a block
let g:dein#mod#hook_end_regexp = get(g:, 'dein#mod#hook_end_regexp',
  \ g:dein#mod#hook_comment_regexp . '\s\+}')

"
" A function to add plugins with hooks
"
function! dein#mod#add(repo, options = {}) abort
  if get(a:options, 'if', v:true) == v:false
    return
  endif

  if g:dein#mod#hook_dir ==# ''
    throw '[dein-mod] g:dein#mod#hook_dir is not set'
  endif

  let plugin = dein#parse#_dict(dein#parse#_init(a:repo, a:options))
  let options = a:options
  let options.ftplugin = {}

  let plugin_name = fnamemodify(plugin.name, ':r')
  let filename = fnamemodify(g:dein#mod#hook_dir . '/' . plugin_name, ':p')

  let filepath = ''

  if filereadable(filename . '.vim')
    let filepath = filename . '.vim'
  endif

  if filereadable(filename . '.lua')
    let filepath = filename . '.lua'
  endif

  if filepath !=# ''
    let hook_type = ''
    let hook_string = ''

    let lines = readfile(filepath)

    for line in lines
      if hook_type ==# ''
        let hook_type = matchstr(line, g:dein#mod#hook_type_regexp)
        continue
      endif

      if line ==# '' || line =~# g:dein#mod#hook_comment_regexp . '\s\*$'
        continue
      endif

      if matchstr(line, g:dein#mod#hook_end_regexp) !=# ''
        execute printf('let options.%s = hook_string', hook_type)

        let hook_type = ''
        let hook_string = ''

        continue
      endif

      let hook_string .= line . "\n"
    endfor
  endif
  " echomsg printf('[dein-mod] Added %s: options = %s', plugin.name, options)
  call dein#add(a:repo, options)
endfunction

