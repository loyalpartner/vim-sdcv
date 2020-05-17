# vim-sdcv
![sdcv](./sdcv_vim.gif)
在vim里面使用sdcv，支持vim和neovim。

配置方法:
```
" 如果不配置，默认使用所有字典
let g:sdcv_dictionary_simple_list = [
			\"懒虫简明英汉词典",
			\"懒虫简明汉英词典",
			\"朗道英汉字典5.0",
			\"朗道汉英字典5.0",
			\"新华字典",
			\]
" 绑定快捷键
nnoremap <silent> g. :<c-u>call sdcv#search_pointer()<cr>
vnoremap <silent> g. v:<c-u>call sdcv#search_pointer("")<cr>
```

# TODO
[x] 能够查询短语
[x] 添加可控制的宽度
[x] 复杂查询


