# vim-sdcv
![sdcv](./sdcv_vim.gif)
在vim里面使用sdcv，支持vim和neovim。

支持骆驼命名分词, 例如: `AppName` 会分成 App 和 Name，当光标位于 App 上时，会查询 App，当光标位于 Name，则会查询 Name。

## 配置:


### 绑定快捷键
```vimscript
nnoremap g.  :<c-u>call sdcv#search_pointer("n")<cr>
vnoremap g. v:<c-u>call sdcv#search_pointer("v")<cr>
nnoremap g>  :<c-u>call sdcv#search_detail_pointer("n")<cr>
vnoremap g> v:<c-u>call sdcv#search_detail_pointer("v")<cr>
```

### 字典设置
vim-sdcv 有两个字典集， 

`sdcv_dictionary_simple_list` 这个字典集设置一些信息量少的字典

`sdcv_dictionary_complete_list` 这个字典集设置信息量复杂的字典

注意：windows 会默认使用所有字典，sdcv 目前无法使用包含中文的 -u 选项
```
let g:sdcv_dictionary_simple_list = [
			\"懒虫简明英汉词典",
			\"懒虫简明汉英词典",
			\"朗道英汉字典5.0",
			\"朗道汉英字典5.0",
			\"新华字典",
			\]

let g:sdcv_dictionary_complete_list = [
			\"牛津英汉双解美化版",
			\"懒虫简明英汉词典",
			\"懒虫简明汉英词典",
			\"朗道英汉字典5.0",
			\"朗道汉英字典5.0",
			\"新华字典",
			\]

```

### 使用:

sdcv#search_detail_pointer() 查询开始后光标会聚焦在 popup window 上，你可以用下面的快捷键操作


```
 q 退出
 <c-n> 跳到下一个字典
 <c-p> 跳到上一个字典
```


[windows 安装 sdcv 的方法](./compile-sdcv-in-msys2.md)

### TODO:
1. 用命令替换函数
