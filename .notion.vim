let $root = "/home/dima/documents/notion"

func! ChangeDir(path, write)
  call chdir(a:path)
  edit _
  if a:write
    call WriteMotionHistory()
  endif
endfunc

func! JumpNote()
  if !isdirectory(expand("<cword>"))
    call mkdir(expand("<cword>"))
  endif
  let path = expand("<cword>")
  call ChangeDir(path, 1)
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
  let path = expand("%:p:h:h")
  if path != $HOME .. "/documents"
    call ChangeDir(path, 1)
  endif
endfunc

func! GoBack()
  let pathlist = readfile($root .. "/.motion_history")
  call remove(pathlist, -1)
  call writefile(pathlist, $root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  call ChangeDir(path, 0)
endfunc

func! WriteMotionHistory()
  call writefile([expand("%:p:h")], $root .. "/.motion_history", "a")
endfunc

func! GoHome()
  call ChangeDir($root, 1)
endfunc

func! RestorePath()
  let pathlist = readfile($root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  call ChangeDir(path, 0)
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
  call ChangeDir(path, 1)
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
  let header = expand("%:p:h")
  let header = copy("# " .. header)
  call setpos(".", [0, 1, 1, 0, 1])
  autocmd! TextChanged,TextChangedT,ModeChanged
  execute "normal O"
  execute "normal O" .. header
  autocmd TextChanged,TextChangedT,ModeChanged * call UpdateFile()
  let cursorpos[1] = copy(cursorpos[1] + 2)
  call setpos(".", cursorpos)
endfunc

func! RemoveExtras()
  let cursorpos = getcurpos()
  call setpos(".", [0, 1, 1, 0, 1])
  autocmd! TextChanged,TextChangedT,ModeChanged
  normal 2dd
  call histdel("", -2)
  autocmd TextChanged,TextChangedT,ModeChanged * call UpdateFile()
  let cursorpos[1] = copy(cursorpos[1] - 2)
  call setpos(".", cursorpos)
endfunc

func! UpdateFile()
  update
"  execute "normal :3,$w!\<CR>"
endfunc

func! Quit()
  execute "normal :q!\<CR>"
endfunc

func! Link()
  let link_name = expand("%:p:h") .. "/" .. expand("<cword>")
  vim9cmd execute "normal :!ln -s " .. $old_filename .. " " .. link_name .. "\<CR>"
endfunc

nnoremap er :call Remove()<CR>
nnoremap ef :call JumpNote()<CR>
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
autocmd TextChanged,TextChangedT,ModeChanged * call UpdateFile()
autocmd! TextChangedI
autocmd ExitPre,QuitPre * call Quit()

call RestorePath()
set syntax=markdown
set iskeyword+=/,.
