---
layout:     post
title:      Ubuntu安装docker和docker-compose
date:       2021-5-23
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
---
# 安装
1. 卸载旧版本
    Docker的旧版本被称为docker，docker.io或docker-engine。如果安装了这些，请卸载它们：
    ```
    sudo apt-get remove docker docker-engine docker.io containerd runc
    ```
2. 更新apt包索引并安装包以允许apt通过 HTTPS 使用存储库
    ```
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg lsb-release
    ```
3. 添加Docker官方的GPG密钥
    ```
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```
4. 使用以下命令设置稳定存储库。
    ```
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```
5. 更新apt包索引，安装最新版本的Docker Engine和containerd
    ```
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```
    要安装特定版本的 Docker Engine，列出您的存储库中可用的版本，然后选择一个并安装。
    ```
    apt-cache madison docker-ce
    sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
    ```

6. 通过运行hello-world 映像验证 Docker Engine 是否已正确安装
    ```
    sudo docker run hello-world
    ```
7. Docker Compose 依赖 Docker Engine 进行任何有意义的工作，因此请确保根据您的设置，在本地或远程安装了 Docker Engine。
   运行此命令以下载 Docker Compose 的当前稳定版本。
    ```
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```
8. 对二进制文件应用可执行权限。
    ```
    sudo chmod +x /usr/local/bin/docker-compose
    ```
9. 测试docker-compose安装是否成功。
    ```
    docker-compose --version
    ```

# 卸载
1. 卸载 Docker Engine、CLI 和 Containerd 包。
    ```
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    ```
2. 主机上的映像、容器、卷或自定义配置文件不会自动删除。删除所有镜像、容器和卷。
    ```
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    ```
3. 卸载 Docker Compose
    ```
    sudo rm /usr/local/bin/docker-compose
    ```