" Searching word with sdcv at Vim.

autocmd filetype sdcv nnoremap q :close!<cr>
autocmd filetype sdcv nnoremap <c-p> ?-->.*\n--><cr>zt
autocmd filetype sdcv nnoremap <c-n> /-->.*\n--><cr>zt

if !exists("g:sdcv_dictionary_simple_list")
  let g:sdcv_dictionary_simple_list = []
end

if !exists("g:sdcv_dictionary_complete_list")
  let g:sdcv_dictionary_complete_list = []
end

let s:winid = 0

" nvim {{{
function! s:sdcv_search_with_dictionary(word, dict_list)
  if len(a:dict_list) > 0 && has("unix")
    let dict_args = "-u " . join(a:dict_list, " -u ")
  else
    let dict_args = ""
  endif

  let sdcv_cmd = 'sdcv --utf8-output --utf8-input ' . dict_args .  ' -n "' . a:word . '"'
  let result = system(sdcv_cmd)

  return result
endfunction

function! s:sdcv_formart_result(result) abort
  let result = substitute(a:result, "[\\.] \\*", "\n*", "g")
  let result = substitute(a:result, " \\(\\d [([]\\)", "\n\\1", "g")
  let result = substitute(a:result, "\\(\\d [([]\\)", "\n\\1", "g")
  let result = substitute(a:result, " \\((\\w)\\)", "\n\\1", "g")
  return result
endfunction

function! s:sdcv_nvim_show_simple_result(word, text)
  let buf = nvim_create_buf(v:false, v:true)
  let opts = {'relative': 'cursor', 'width': 50, 'height': 30, 'col': 0,
        \ 'row': 1, 'style': 'minimal', 'focusable': 0}
  let s:winid = nvim_open_win(buf, 0, opts)
  " optional: change highlight, otherwise Pmenu is used
  call nvim_win_set_option(s:winid, 'winhl', 'Normal:MyHighlight')
  call nvim_buf_set_lines(buf, 0, -1, v:true, split(a:text, '\n'))
  autocmd CursorMoved <buffer> ++once call nvim_win_close(s:winid, v:false)
endfunction

function! s:sdcv_nvim_show_detail_result(word, text)
  let text = "type q to exit, <c-n> next dict, <c-p> prev dict \n\n" . a:text

  let height = &lines - 3
  let width = float2nr(&columns - (&columns * 2 / 10))
  let col = float2nr((&columns - width) / 2)

  let opts = {
        \'relative': 'editor',
        \'row': height * 0.3,
        \'col': col + 30,
        \'width': width * 3 / 4,
        \'height': height / 2,
        \'focusable': 1
        \}

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)

  " optional: change highlight, otherwise Pmenu is used
  call nvim_win_set_option(win, 'winhl', 'Normal:Pmenu')

  setlocal
        \ buftype=nofile
        \ filetype=sdcv
        \ nobuflisted
        \ bufhidden=hide
        \ number
        \ nohlsearch
        \ nowrap
        \ norelativenumber
        \ signcolumn=no

  call nvim_buf_set_lines(buf, 0, -1, v:true, split(a:text, '\n'))
endfunction

function! s:sdcv_nvim_show_result(word,text,type)
  if a:type == "simple"
    call s:sdcv_nvim_show_simple_result(a:word, a:text)
  else
    call s:sdcv_nvim_show_detail_result(a:word, a:text)
  end
endfunction
" }}}

" vim8
let s:sdcv_vim8_dict_lines = []

function! SDCV_VIM8_POPUP_FILTER(id, key)
  let pp = popup_getpos(a:id)
  if a:key == "q" || a:key == ""
    call feedkeys("\<Esc>")
    call popup_close(a:id, 1)
  elseif a:key == "" || a:key == ""

    let index = index(s:sdcv_vim8_dict_lines, pp.firstline)

    let index = a:key == "" ? 
          \ (index >= 0 ? index + 1 : 0) :
          \ (index >= 1 ? index - 1 : 0)

    call popup_setoptions( a:id,
          \ {'firstline' : get(s:sdcv_vim8_dict_lines, index)} )
  end
endfunction


function! SDCV_VIM8_POPUP_CALLBACK(id, result)
  call setpos(".", s:sdcv_vim8_last_position)
endfunction


function! s:sdcv_vim8_get_dict_postion(word, lines)
  for i in range(len(a:lines))
    let line = get(a:lines, i)
    if matchstr(line, "-->".a:word) != ""
      let index = i - 1
      call add(s:sdcv_vim8_dict_lines, index) 
    endif
  endfor
endfunction

function! s:sdcv_vim8_show_simple_result(word,text)
  let s:winid = popup_create("sdcv", #{
        \ border: [1,1,1,1],
        \ padding: [0,1,0,1],
        \ maxheight: 50,
        \ filter: "SDCV_VIM8_POPUP_FILTER"
        \})

  let bufnr = winbufnr(s:winid)
  let lines = split(a:text, '\n')

  for line in a:text
    call appendbufline(bufnr, "$", line)
  endfor
endfunction

function! s:sdcv_vim8_show_detail_result(word,text)

  let height = &lines - 3
  let width = float2nr(&columns - (&columns * 2 / 10))
  let col = float2nr((&columns - width) / 2)

  let win = popup_create("", #{
        \ scrollbar: 1,
        \ border: [1,1,1,1],
        \ padding: [0,1,0,1],
        \ maxwidth: width * 3 / 4,
        \ maxheight: height / 2,
        \ fixed: 1,
        \ mousemoved: 'word',
        \ minwidth: width * 3 / 4,
        \ minmaxheight: height / 2,
        \ time: 1000000,
        \ mapping: 0,
        \ close : "click",
        \ filtermode: "n",
        \ filter: "SDCV_VIM8_POPUP_FILTER",
        \ callback: "SDCV_VIM8_POPUP_CALLBACK"
        \})

  call setwinvar(win, 'float', 1)
  call setwinvar(win, '&wrap', 1)
  call setwinvar(win, '&linebreak', 1)
  call setwinvar(win, '&conceallevel', 2)

  let bufnr = winbufnr(win)
  let lines = split(a:text, '\n')

  let s:sdcv_vim8_dict_lines = []

  call s:sdcv_vim8_get_dict_postion(a:word, lines)

  let s:sdcv_vim8_last_position = getpos(".")
  for line in lines
    call appendbufline(bufnr, "$", line)
    " call popup_settext(win, a:text)
  endfor
endfunction

function! s:sdcv_vim8_show_result(word,text,type)
  if a:type == "simple"
    call s:sdcv_vim8_show_simple_result(a:word, a:text)
  else
    call s:sdcv_vim8_show_detail_result(a:word, a:text)
  end

endfunction
" }}}
"
function! s:sdcv_show_result(word,text,type)
  if exists('*nvim_open_win')
    call s:sdcv_nvim_show_result(a:word,a:text,a:type)
  elseif exists('*popup_create')
    call s:sdcv_vim8_show_result(a:word,a:text,a:type)
  else
    echo a:text
  end
endfunction

function! s:sdcv_pick_word()

  let text = s:sdcv_replace_nonword_character(expand("<cword>"))

  let pos1 = getpos(".")
  execute "normal b"
  let pos2 = getpos(".")
  call setpos(".", pos1)

  let words = split(text, " ")

  let offset = pos1[2] - pos2[2]
  if pos2[1] < pos1[1] 
    let offset = 0
  endif

  let total = eval(join(map(copy(words), {_,v->strlen(v)}),"+"))
  if offset > total
    return words[0]
  end

  let search_index = 0
  for word in words
    if offset >=  search_index &&  offset < search_index + strlen(word)
      return word
    end

    let search_index = search_index + strlen(word)
  endfor
  return words[-1]
endfunction

function! s:sdcv_replace_nonword_character(word)
  " set ignorecase will change search action.
  " so we need add \c to the pattern.
  let result = substitute(a:word,'\C\([a-z0-9]\)\([A-Z]\)','\1_\2', "g")
  let result = substitute(result,'\C\([A-Z]+\)\([A-Z][a-z]\)','\1_\2', "g")
  let result = substitute(result,'\.','_', "g")
  let result = substitute(result,'-','_', "g")
  let result = substitute(result,'#','_', "g")
  let result = substitute(result,'_+','_', "g")
  let result = substitute(result,'_',' ', "g")
  return result
endfunction

function! s:sdcv_get_visual_selection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - 1]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

function sdcv#search_input(word) abort
  let search_result = s:sdcv_search_with_dictionary(a:word , g:sdcv_dictionary_complete_list)
  call s:sdcv_show_result(a:word, s:sdcv_formart_result(search_result), "detail")
endfunction

function! sdcv#search_selection()
  let word = s:sdcv_get_visual_selection()
  let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
  call s:sdcv_show_result(word, search_result, "simple")
endfunction

function! sdcv#search_detail_selection()
  let word = s:sdcv_get_visual_selection()
  let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_complete_list)
  call s:sdcv_show_result(word, s:sdcv_formart_result(search_result), "detail")
endfunction

function! sdcv#search_pointer(...)
  let word = s:sdcv_pick_word()
  let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
  call s:sdcv_show_result(word, search_result, "simple")
endfunction

function! sdcv#search_detail_pointer(...)
  let word = s:sdcv_pick_word()
  let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_complete_list)
  call s:sdcv_show_result(word, s:sdcv_formart_result(search_result), "detail")
endfunction
