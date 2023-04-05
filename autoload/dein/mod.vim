" A directory where hook files are stored
let g:dein#mod#hook_dir = get(g:, 'dein#mod#hook_dir', '')

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

  let plugin_name = fnamemodify(plugin.name, ':r')
  let filename = fnamemodify(g:dein#mod#hook_dir . '/' . plugin_name, ':p')

  let vim_path = filename . '.vim'
  let lua_path = filename . '.lua'

  let vim_exists = filereadable(vim_path)
  let lua_exists = filereadable(lua_path)

  let filepath = vim_exists ? vim_path : (lua_exists ? lua_path : '')

  if filepath !=# ''
    let commenter = vim_exists ? '^"' : '^--'
    let regexp_start = commenter . ' \zs\(hook_\|lua_\|ftplugin: \)\S\+\ze {'
    let regexp_end = commenter . ' }'

    let hook_type = ''
    let hook_string = ''

    let lines = readfile(filepath)

    for line in lines
      if line ==# '' || line =~# commenter . '\s*$'
        continue
      endif

      if hook_type ==# ''
        let hook_type = matchstr(line, regexp_start)
        continue
      endif

      let str_end = matchstr(line, regexp_end)

      if str_end !=# ''
        let filetype = matchstr(hook_type, 'ftplugin: \zs\S\+')

        if filetype !=# ''
          let options.ftplugin = get(options, 'ftplugin', {})
          execute printf('let options.ftplugin["%s"] = hook_string', filetype)
        else
          execute printf('let options["%s"] = hook_string', hook_type)
        endif

        let hook_type = ''
        let hook_string = ''
        continue
      endif

      let hook_string .= line . "\n"
    endfor
  endif

  call dein#add(a:repo, options)
endfunction

