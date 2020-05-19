" Searching word with sdcv at Vim.

autocmd filetype sdcv nnoremap q :close!<cr>
autocmd filetype sdcv nnoremap <c-p> ?-->.*\n--><cr>zt
autocmd filetype sdcv nnoremap <c-n> /-->.*\n--><cr>zt

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

	" format result
	let result = substitute(result, "[\\.] \\*", "\n*", "g")
	let result = substitute(result, " \\(\\d [([]\\)", "\n\\1", "g")
	let result = substitute(result, "\\(\\d [([]\\)", "\n\\1", "g")
	let result = substitute(result, " \\((\\w)\\)", "\n\\1", "g")

	return result
endfunction

" TODO: add border and padding.
function! s:centered_floating_window()
	let width = min([&columns - 4, max([80, &columns - 20])])
	let height = min([&lines - 4, max([20, &lines - 10])])
	let top = ((&lines - height) / 2) - 1
	let left = (&columns - width) / 2
	let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

	let top = "╭" . repeat("─", width - 2) . "╮"
	let mid = "│" . repeat(" ", width - 2) . "│"
	let bot = "╰" . repeat("─", width - 2) . "╯"
	let lines = [top] + repeat([mid], height - 2) + [bot]
	let s:buf = nvim_create_buf(v:false, v:true)
	call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
	call nvim_open_win(s:buf, v:true, opts)
	set winhl=Normal:Floating
	let opts.row += 1
	let opts.height -= 2
	let opts.col += 2
	let opts.width -= 4
	call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
	au BufWipeout <buffer> exe 'bw '.s:buf
endfunction
"call sdcv#centered_floating_window(1)

function! s:sdcv_nvim_show_result(text)

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

 	call nvim_buf_set_lines(buf, 0, -1, v:true, split(text, '\n'))
 	" autocmd CursorMoved <buffer> ++once call nvim_win_close(s:win, v:false)
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

function! sdcv#search_selection()
	let word = s:sdcv_get_visual_selection()
	let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
	call s:sdcv_show_result(search_result)
endfunction

function! sdcv#search_pointer(...)
	let word = s:sdcv_pick_word()
	let search_result = s:sdcv_search_with_dictionary(word , g:sdcv_dictionary_simple_list)
	call s:sdcv_show_result(search_result)
endfunction
