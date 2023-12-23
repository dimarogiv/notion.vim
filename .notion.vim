let $root = "/home/dima/documents/notion"

func! ChangeDir()
  if !isdirectory(expand("<cword>"))
    call mkdir(expand("<cword>"))
  endif
  let path = expand("<cword>")
"  call RemoveExtras()
  call chdir(path)
  edit _
  call WriteMotionHistory()
"  call AddExtras()
endfunc

func! Remove()
  if len(system("stat " .. expand("<cword>") .. " | grep 'symbolic link'")) == 0
    let message = system("rm -rv " .. expand("<cword>") .. " 2>&1 && echo Note removed")
  else
    let message = system("rm -v " .. expand("<cword>") .. " 2>&1 && echo Link removed")
  endif
  call popup_notification(message,#{time: 3000})
endfunc

func! LevelUp()
  if expand("%:p:h:h") != $HOME .. "/documents"
    call chdir(expand("%:p:h:h"))
    edit _
    call WriteMotionHistory()
  endif
endfunc

func! GoBack()
  let pathlist = readfile($root .. "/.motion_history")
  call remove(pathlist, -1)
  call writefile(pathlist, $root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  call chdir(path)
  edit _
endfunc

func! WriteMotionHistory()
  call writefile([expand("%:p:h")], $root .. "/.motion_history", "a")
endfunc

func! GoHome()
  call chdir($root .. "")
  edit _
  call writefile([expand("%:p:h")], $root .. "/.motion_history", "a")
endfunc

func! RestorePath()
  let pathlist = readfile($root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  call chdir(path)
  edit _
endfunc

func! WritePath()
  call writefile([expand("%:p:h")],$root .. "/.last_path")
endfunc

func! Rename()
  let new_name = expand("%:p:h") .. "/" .. expand("<cword>")
  vim9cmd execute "normal :!mv " .. $old_filename .. " " new_name .. "\<CR>"
endfunc

func! Choose()
  let $old_filename = expand("%:p:h") .. "/" .. expand("<cword>")
  echo $old_filename
endfunc

func! GoSearchResult(id, result)
  let path = split(b:listtogo[a:result-1], ":\t")[0]
  call chdir(path)
  edit _
  call writefile([expand("%:p:h")], $root .. "/.motion_history", "a")
  call search(g:pattern)
endfunc

func! SearchNote()
  call inputsave()
  let g:pattern = input('Search: ')
  call inputrestore()
  let b:list = systemlist("grep -R \"" .. g:pattern .. "\" " .. $root .. " 2>&1 | grep -v 'grep:' | sed 's/\\/_:/:\\t\\t/'")
  if len(b:list) == 0
    return
  endif
  let b:listtogo = copy(b:list)
  let listtoshow = copy(b:list)
  for item in range(len(b:list))
    let listtoshow[item] = split(b:list[item], "/notion")[1]
  endfor
  call popup_menu(listtoshow, #{callback: "GoSearchResult"})
endfunc

func! AddExtras()
  let cursorpos = getcurpos()
  call setpos(".", [0, 1, 1, 0, 1])
  autocmd! TextChanged,TextChangedT,ModeChanged
  normal O
  normal O
  normal ihello
  call histdel("", -3)
  autocmd TextChanged,TextChangedT,ModeChanged * update
  let cursorpos[1] = copy(cursorpos[1] + 2)
  call setpos(".", cursorpos)
endfunc

func! RemoveExtras()
  let cursorpos = getcurpos()
  call setpos(".", [0, 1, 1, 0, 1])
  autocmd! TextChanged,TextChangedT,ModeChanged
  normal 2dd
  call histdel("", -2)
  autocmd TextChanged,TextChangedT,ModeChanged * update
  let cursorpos[1] = copy(cursorpos[1] - 2)
  call setpos(".", cursorpos)
endfunc

func! UpdateFile()
  call RemoveExtras()
  update
  call AddExtras()
endfunc

func! Link()
  let link_name = expand("%:p:h") .. "/" .. expand("<cword>")
  vim9cmd execute "normal :!ln -s " .. $old_filename .. " " .. link_name .. "\<CR>"
endfunc

nnoremap er :call Remove()<CR>
nnoremap ef :call ChangeDir()<CR>
nnoremap eu :call LevelUp()<CR>
nnoremap ec :call Choose()<CR>
nnoremap en :call Rename()<CR>
nnoremap es :call SearchNote()<CR>
nnoremap ea :call AddExtras()<CR>
nnoremap eo :call RemoveExtras()<CR>
nnoremap eh :call GoHome()<CR>
nnoremap eb :call GoBack()<CR>
nnoremap el :call Link()<CR>

autocmd BufRead * set syntax=markdown
autocmd TextChanged,TextChangedT,ModeChanged * update
autocmd! TextChangedI
autocmd ExitPre,QuitPre * call WritePath()

call RestorePath()
"call AddExtras()
set syntax=markdown
set iskeyword+=/,.
