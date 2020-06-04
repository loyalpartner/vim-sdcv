if exists("g:loaded_sdcv") 
  finish
endif

let g:loaded_sdcv = 1

command! -nargs=1 Sdcv :call sdcv#search_input(<q-args>)
command! SdcvPointer :call sdcv#search_pointer("n")


function! s:opfunc(type, ...) abort " {{{1
  if a:type ==# 'setup'
    let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
    return 'g@'
  endif

  let reg = '"'
  let reg_save = getreg(reg)
  if a:type == 'char'
    silent exe 'norm! v`[o`]"'.reg.'y'
  elseif a:type == "line"
    silent exe 'norm! `[V`]"'.reg.'y'
  end
  call sdcv#search_selection()
  call setreg(reg, reg_save)
endfunction

nnoremap <expr> <Plug>Sdcv <SID>opfunc('setup')
nnoremap <Plug>SdcvPointer :call sdcv#search_pointer("n")<cr>
nnoremap <Plug>SdcvPointer+ :call sdcv#search_detail_pointer("n")<cr>
vnoremap <Plug>SdcvPointerV :call sdcv#search_pointer("v")<cr>
vnoremap <Plug>SdcvPointerV+ :call sdcv#search_detail_pointer("v")<cr>

nmap gs <Plug>Sdcv
