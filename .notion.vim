let $root = $NOTION_DIR
let $history_len = 100
let $logfile = "/dev/pts/1"

func! WriteLog(text)
  let logstr = strftime("%X") .. ": " .. a:text
  call writefile([logstr], $logfile)
endfunc

func! GoToNote(path)
  let path = fnamemodify(a:path, ":p:h")
  call WriteLog(path)
  if match(path, $root) >= 0
    if isdirectory(path)
      call chdir(path)
      edit _
    elseif filereadable(path)
      edit path
    else
      call mkdir(path)
      call chdir(path)
      edit _
    endif
  else
    call WriteLog("error: " .. path .. ": the path is unaccessbile!" .. ": match() returns: " .. match(path, $root))
  endif
endfunc

func! WGoToNote(path)
  call GoToNote(a:path)
  call WriteMotionHistory()
endfunc

func! Remove()
  if len(system("stat " .. expand("<cword>") .. " | grep 'symbolic link'")) == 0
    let message = system("rm -rv " .. expand("<cword>") .. " 2>&1 && echo Note removed")
  else
    let message = system("rm -v " .. expand("<cword>") .. " 2>&1 && echo Link removed")
  endif
  call popup_notification(message,#{time: 3000})
endfunc

func! GoBack()
  let pathlist = readfile($root .. "/.motion_history")
  call remove(pathlist, -1)
  call writefile(pathlist, $root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  if path == "/"
    let path = $root
  else
    let path = $root .. path
  endif
  call WriteLog("GoBack: " .. path)
  call GoToNote(path)
endfunc

func! WriteMotionHistory()
  let path = expand("%:p:h")
  if !len(split(path, $root))
    let path = "/"
  else
    let path = split(path, $root)[0]
  endif
  call WriteLog("Written to /.motion_history: " .. path)
  let pathlist = readfile($root .. "/.motion_history")
  let pathlist = add(copy(pathlist), copy(path))
  if len(pathlist) > $history_len
    let pathlist = copy(pathlist)[0-$history_len:]
  endif
  call writefile(pathlist, $root .. "/.motion_history", "s")
endfunc

func! RestorePath()
  let pathlist = readfile($root .. "/.motion_history")
  let path = copy(pathlist[len(pathlist)-1])
  if path == "/"
    let path = $root
  else
    let path = $root .. path
  endif
  call WriteLog("RestorePath: " .. path)
  call GoToNote(path)
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
  call WGoToNote(path)
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
    let listtoshow[item] = split(b:list[item], $root)[0]
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
nnoremap ef :call WGoToNote(expand("<cword>"))<CR>
nnoremap eu :call WGoToNote(expand("%:p:h:h"))<CR>
nnoremap ec :call Choose()<CR>
nnoremap en :call Rename()<CR>
nnoremap es :call SearchNote()<CR>
nnoremap ea :call AddExtras()<CR>
nnoremap eo :call RemoveExtras()<CR>
nnoremap eh :call WGoToNote($root)<CR>
nnoremap eb :call GoBack()<CR>
nnoremap el :call Link()<CR>

autocmd BufRead * set syntax=markdown
autocmd TextChanged,TextChangedT,ModeChanged * call UpdateFile()
autocmd! TextChangedI
autocmd ExitPre,QuitPre * call Quit()

call RestorePath()
set syntax=markdown
set iskeyword+=/,.
