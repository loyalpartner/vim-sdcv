# vim-sdcv

English|[ 中 文 ](./README.zh-cn.md)

![sdcv](./sdcv_vim.gif)

Use SDCV inside VIM, support VIM and NEOVIM.

Supports camel naming participles, e.g. AppName splits into App and Name, queries App when the cursor is on App and Name when the cursor is on Name.

## Preference:

### Binding shortcuts.
```vimscript
nnoremap g. :<c-u>call sdcv#search_pointer("n")<cr>
vnoremap g. v:<c-u>call sdcv#search_pointer("v")<cr>
nnoremap g> :<c-u>call sdcv#search_detail_pointer("n")<cr>
vnoremap g> v:<c-u>call sdcv#search_detail_pointer("v")<cr>
````

### Dictionary Settings

The VIM-SDCV has two dictionary sets. 

`s:sdcv_dictionary_simple_list` This dictionary set sets up dictionaries that are less informative.

`s:sdcv_dictionary_complete_list` This dictionary set sets up dictionaries with complex information

Note: Windows uses all dictionaries by default, sdcv is currently unable to use the -u option with Chinese

````
let g:sdcv_dictionary_simple_list = [
                        \"Lazybones Concise English-Chinese Dictionary",
                        \"Lazybones Concise Chinese and English Dictionary",
                        \"Landau English-Chinese Dictionary 5.0",
                        \"Landau Chinese and English Dictionary 5.0",
                        \"Xinhua Dictionary",
                        \]

let g:sdcv_dictionary_complete_list = [
                        \"Oxford English and Chinese Doubled Up Edition",
                        \"Lazybones Concise English-Chinese Dictionary",
                        \"Lazybones Concise Chinese and English Dictionary",
                        \"Landau English-Chinese Dictionary 5.0",
                        \"Landau Chinese and English Dictionary 5.0",
                        \"Xinhua Dictionary",
                        \]

````

### Use:

sdcv#search_detail_pointer() The cursor will focus on the popup window when the query starts, which you can do using the following shortcut


````
 q Exit
 <c-n> Skip to the next dictionary.
 <c-p> Skip to previous dictionary
````



Translated with www.DeepL.com/Translator (free version)

[windows 安装 sdcv 的方法](./compile-sdcv-in-msys2.md)
