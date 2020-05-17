## windows 里面编译 sdcv

1. 安装 msys2
推荐使用 `scoop` 
```
scoop install msys2
```
2. 打开 msys2

3. 添加编译所需要的依赖
```
pacman -S cmake gcc make glib2-devel libreadline-devel zlib-devel gettext-devel git
```

3. 下载并编译源码
```
git clone https://github.com/et2010/sdcv.git
mkdir sdcv/build
cd sdcv/build
cmake
make lang
make install
```
