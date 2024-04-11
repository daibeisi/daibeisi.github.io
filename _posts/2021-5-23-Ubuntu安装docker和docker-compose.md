---
layout:     post
title:      Ubuntu安装docker和docker-compose
date:       2021-5-23
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
tags:
    - Docker
---
## 安装

1. 卸载旧版本
    Docker的旧版本被称为docker，docker.io或docker-engine。如果安装了这些，请卸载它们：

    ```bash
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
    ```

    apt-get可能会报告您没有安装这些软件包。当您卸载 Docker 时，存储在其中的图像、容器、卷和
    网络/var/lib/docker/不会自动删除。如果您想从全新安装开始，并且更愿意清理任何现有数据，
    请阅读 卸载 Docker 引擎部分。

2. 更新apt包索引并安装包以允许apt通过 HTTPS 使用存储库

    ```bash
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    ```

3. 添加Docker官方的GPG密钥

    ```bash
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    ```

4. 使用以下命令设置稳定存储库。

    ```bash
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

5. 更新apt包索引，安装最新版本的Docker Engine和containerd

    ``` shell
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

    要安装特定版本的 Docker Engine，列出您的存储库中可用的版本，然后选择一个并安装。

    ``` shell
    apt-cache madison docker-ce | awk '{ print $3 }'
    VERSION_STRING=5:24.0.0-1~ubuntu.22.04~jammy
    sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
    ```

6. 修改/etc/bash.bashrc
   添加`alias docker-compose='docker compose'`到文件中后执行命令`source /etc/bash.bashrc`

7. 通过运行hello-world 映像验证 Docker Engine 是否已正确安装

    ```bash
    sudo docker run hello-world
    ```

8. 测试docker-compose安装是否成功。

    ```bash
    docker-compose --version
    ```

## 以非 root 用户身份管理 Docker

Docker 守护进程绑定到 Unix 套接字，而不是 TCP 端口。默认情况下，它是 root拥有 Unix 套接字的用户，
其他用户只能使用 sudo. Docker 守护进程始终以root用户身份运行。

如果您不想在docker命令前加上sudo，请创建一个名为 docker 的 Unix 组并将用户添加到其中。
当 Docker 守护进程启动时，它会创建一个可供组成员访问的 docker Unix 套接字。
在某些 Linux 发行版上，系统会在使用包管理器安装 Docker Engine 时自动创建此组。在这种情况下，您无需手动创建组。

1. 创建docker组。

   ```bash
   sudo groupadd docker
   ```

2. 将您的用户添加到docker组中。

   ```bash
   sudo usermod -aG docker $USER
   ```

3. 注销并重新登录，以便重新评估您的组成员身份。
   如果您在虚拟机中运行 Linux，可能需要重新启动虚拟机才能使更改生效。您还可以运行以下命令来激活对组的更改。

   ```bash
   newgrp docker
   ```

4. 验证您是否可以在没有 sudo 下运行 docker.

   ```bash
   docker run hello-world
   ```

## 配置Docker守护进程

您可以通过修改daemon配置文件/etc/docker/daemon.json来配置Docker守护进程。

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "default-shm-size": "1GB",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "log-driver": "json-file",
  "log-level": "",
  "log-opts": {
    "cache-disabled": "false",
    "cache-max-file": "5",
    "cache-max-size": "20m",
    "cache-compress": "true",
    "env": "os,customer",
    "labels": "somelabel",
    "max-file": "5",
    "max-size": "10m"
  },
  "registry-mirrors": ["https://*.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

[docker配置选项的完整示例](https://docs.docker.com/engine/reference/commandline/dockerd/#on-linux)

## 用systemd配置Docker在开机时启动

许多现代Linux发行版使用systemd来管理系统启动时的服务。在Debian和Ubuntu上，Docker服务默认在启动时启动。
在其他使用systemd的Linux发行版上，要在开机时自动启动Docker和containerd，请运行以下命令：

```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

要停止这种行为，请使用disable代替。

```bash
sudo systemctl disable docker.service
sudo systemctl disable containerd.service
```

## 卸载

1. 卸载 Docker Engine、CLI 和 Containerd 包。

    ```bash
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    ```

2. 主机上的映像、容器、卷或自定义配置文件不会自动删除。删除所有镜像、容器和卷。

    ```bash
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    ```
