if exists("g:loaded_sdcv") 
  finish
endif

let g:loaded_sdcv = 1

command! -nargs=1 SDCV :call sdcv#search_input(<q-args>)
