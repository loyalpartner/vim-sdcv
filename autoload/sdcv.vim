" Searching word with sdcv at Vim.

if !exists("g:sdcv_dictionary_simple_list")
	let g:sdcv_dictionary_simple_list = []
end

let s:winid = 0

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

function! s:sdcv_nvim_show_result(text)

	let lines = split(a:text, '\n')
	let buf = nvim_create_buf(v:false, v:true)
	call nvim_buf_set_lines(buf, 0, -1, v:true, lines)
	let opts = {'relative': 'cursor', 'width': 60, 'height': 30, 'col': 0,
				\ 'row': 1, 'style': 'minimal', 'focusable': 0}
	let s:winid = nvim_open_win(buf, 0, opts)
	" optional: change highlight, otherwise Pmenu is used
	call nvim_win_set_option(s:winid, 'winhl', 'Normal:MyHighlight')
	autocmd CursorMoved <buffer> ++once call nvim_win_close(s:winid, v:false)
endfunction


function! SDCV_POPUP_FILTER(id, key)
	call popup_close(a:id, 1)
endfunction

function! s:sdcv_vim8_show_result(text)

	let s:winid = popup_create("sdcv", #{
				\ scrollbar: 1,
				\ border: [1,1,1,1],
				\ padding: [0,1,0,1],
				\ maxheight: 50,
				\ filter: "SDCV_POPUP_FILTER"
				\})

	let bufnr = winbufnr(s:winid)
	let lines = split(a:text, '\n')

	for line in lines
		call appendbufline(bufnr, "$", line)
	endfor
endfunction

function! s:sdcv_show_result(text)
	if exists('*nvim_open_win')
		call s:sdcv_nvim_show_result(a:text)
	elseif exists('*popup_create')
		call s:sdcv_vim8_show_result(a:text)
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
	if pos2[1] < pos1[1] || offset > strlen(text)
		let offset = 0
	endif

	let search_index = 0
	for word in words
		if offset >=  search_index &&  offset <= search_index + strlen(word)
			return word
		end

		let search_index = search_index + strlen(word)
	endfor
endfunction

function! s:sdcv_replace_nonword_character(word)
	let result = substitute(a:word,'\([a-z0-9]\)\([A-Z]\)','\1_\2', "g")
	let result = substitute(result,'\([A-Z]+\)\([A-Z][a-z]\)','\1_\2', "g")
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

function! sdcv#search_pointer_visual()
	let word = s:sdcv_get_visual_selection()
	let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
	call s:sdcv_show_result(search_result)
endfunction

function! sdcv#search_pointer(...)
	let word = s:sdcv_pick_word()
	let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
	call s:sdcv_show_result(search_result)
endfunction

function! sdcv#search_simple(word)
	let word = s:sdcv_replace_nonword_character(a:word)
	let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
	call s:sdcv_show_result(search_result)
endfunction
