---
layout:     post
title:      go和goland安装配置
date:       2023-3-25
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
catalog: true
tags:
    - go
---
# 安装
1. 到 [go官网下载](https://go.dev/dl/)找到对应安装包链接下载。
    ![](/img/go-download.png)

2. 一路next安装，打开终端输入`go version`,如看到下图则代表安装成功。
    ![](/img/go-version.png)

3. 打开GO111MODULE,更改go代理。
    ```
    $ go env -w GO111MODULE=on
    $ go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
    ```

4. 到[jetbrains官网 GoLand工具下载](https://www.jetbrains.com/go/download/)
   找到对应安装包下载。
    ![](/img/goland-download.png)

5. 新建一个测试项目。
    ![](/img/go-project-create.png)

6. 创建hello.go文件，将以下代码写入并运行。
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Println("Hello, World!")
    }
    ```

7. 设置 GoLand 的 File Watcher。
    ![](/img/goland-filewatcher.png)

# 卸载
在 设置/应用与功能 中, 选择 Go Programming Language, 单击 卸载，
然后按照提示进行操作。
