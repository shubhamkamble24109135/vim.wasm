if !exists("g:rustfmt_autosave")
let g:rustfmt_autosave = 0
endif
if !exists("g:rustfmt_command")
let g:rustfmt_command = "rustfmt"
endif
if !exists("g:rustfmt_options")
let g:rustfmt_options = ""
endif
if !exists("g:rustfmt_fail_silently")
let g:rustfmt_fail_silently = 0
endif
let s:got_fmt_error = 0
function! s:RustfmtCommandRange(filename, line1, line2)
let l:arg = {"file": shellescape(a:filename), "range": [a:line1, a:line2]}
return printf("%s %s --write-mode=overwrite --file-lines '[%s]'", g:rustfmt_command, g:rustfmt_options, json_encode(l:arg))
endfunction
function! s:RustfmtCommand(filename)
return g:rustfmt_command . " --write-mode=overwrite " . g:rustfmt_options . " " . shellescape(a:filename)
endfunction
function! s:RunRustfmt(command, curw, tmpname)
if exists("*systemlist")
let out = systemlist(a:command)
else
let out = split(system(a:command), '\r\?\n')
endif
if v:shell_error == 0 || v:shell_error == 3
try | silent undojoin | catch | endtry
call rename(a:tmpname, expand('%'))
silent edit!
let &syntax = &syntax
if s:got_fmt_error
let s:got_fmt_error = 0
call setloclist(0, [])
lwindow
endif
elseif g:rustfmt_fail_silently == 0
let errors = []
for line in out
let tokens = matchlist(line, '^\(.\{-}\):\(\d\+\):\(\d\+\):\s*\(\d\+:\d\+\s*\)\?\s*error: \(.*\)')
if !empty(tokens)
call add(errors, {"filename": @%,
\"lnum":     tokens[2],
\"col":      tokens[3],
\"text":     tokens[5]})
endif
endfor
if empty(errors)
% | " Couldn't detect rustfmt error format, output errors
endif
if !empty(errors)
call setloclist(0, errors, 'r')
echohl Error | echomsg "rustfmt returned error" | echohl None
endif
let s:got_fmt_error = 1
lwindow
call delete(a:tmpname)
endif
call winrestview(a:curw)
endfunction
function! rustfmt#FormatRange(line1, line2)
let l:curw = winsaveview()
let l:tmpname = expand("%:p:h") . "/." . expand("%:p:t") . ".rustfmt"
call writefile(getline(1, '$'), l:tmpname)
let command = s:RustfmtCommandRange(l:tmpname, a:line1, a:line2)
call s:RunRustfmt(command, l:curw, l:tmpname)
endfunction
function! rustfmt#Format()
let l:curw = winsaveview()
let l:tmpname = expand("%:p:h") . "/." . expand("%:p:t") . ".rustfmt"
call writefile(getline(1, '$'), l:tmpname)
let command = s:RustfmtCommand(l:tmpname)
call s:RunRustfmt(command, l:curw, l:tmpname)
endfunction
