1. 获取当前分支的 commit id
```
git rev-parse --short HEAD  # 短
git rev-parse HEAD  # 完整
```
2. clone 代码到指定文件夹
```
git clone https://github.com/xiaoyekanren/scripts.git [path]
```
3. clone 指定分支
```
git clone -b master https://github.com/xiaoyekanren/scripts.git
```
