if !exist('g:Plugin_dir')
  let g:Plugin_dir = expand('~/.vim/plugins')
endif

let s:plugins_config = fnamemodify(expand('<sfile>'), ':h').'/plugins.yaml'
if !exist('g:user_plugins_file')
  let g:user_plugins_file = g:Plugin_dir . '/local_plugins.yaml'
endif

let s:plugin_setting_dirname = expand('$VIMPATH/core/plugins/')

let s:is_sudo = $SUDO_USER !=# '' && $USER !=# $SUDO_USER
" dein configurations.
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'echo'
let g:dein#enable_notification = 1
let g:dein#install_progress_type = 'title'
let g:dein#install_log_filename = '/tmp/dein.log'
let g:dein#auto_recache = 1

function! s:dein_load_yaml(filename) abort
  " Fallback to use python3 and PyYAML
  python3 << endpython
import vim, yaml
with open(vim.eval('a:filename'), 'r') as f:
  vim.vars['denite_plugins'] = yaml.safe_load(f.read())
endpython
  endif

  for plugin in g:denite_plugins
    call dein#add(plugin['repo'], extend(plugin, {}, 'keep'))
  endfor
  unlet g:denite_plugins
endfunction

function! s:check_file_notnull(filename)abort
  let content = readfile(a:filename)
  if empty(content)
    return 0
  endif
  return 1
endfunction

if dein#load_state(s:path)
  call dein#begin(s:path, [expand('<sfile>'), s:plugins_path])
  try
    call s:dein_load_yaml(s:plugins_path)
    if filereadable(s:user_plugins_path)
      if s:check_file_notnull(s:user_plugins_path)
        call s:dein_load_yaml(s:user_plugins_path)
      endif
    endif
  catch /.*/
    echoerr v:exception
    echomsg 'Error loading config/plugins.yaml...'
    echomsg 'Caught: ' v:exception
    echoerr 'Please run: pip3 install --user PyYAML'
  endtry
  call dein#end()
  if ! s:is_sudo
    call dein#save_state()
  endif

  filetype plugin indent on
  syntax enable

  if dein#check_install()
    " Installation check.
    call dein#install()
    call dein#check_clean()
  endif
endif


function! s:edit_plugin_setting(plugin_name)
  if !isdirectory(s:plugin_setting_dirname)
    call mkdir(s:plugin_setting_dirname)
  endif
  execute 'edit' s:plugin_setting_dirname . '/' . a:plugin_name . '.vim'
endfunction

command! -nargs=1
  \ EditPluginSetting
  \ call s:edit_plugin_setting(<q-args>)
