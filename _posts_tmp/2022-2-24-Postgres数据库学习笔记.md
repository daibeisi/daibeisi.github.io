---
layout:     post
title:      MySQL学习笔记*
subtitle:   ......
date:       2022-5-10
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - 数据库
---
## PostgreSQL简介

## PostgreSQL的安装与配置

### 二进制安装包进行安装
默认情况下，所有 Ubuntu 版本都提供 PostgreSQL。但是，Ubuntu“快照”了一个特定版本的 PostgreSQL，
然后在该 Ubuntu 版本的整个生命周期中都支持该版本。其他版本的 PostgreSQL 可通过 PostgreSQL apt 存储库获得。
如果您的 Ubuntu 版本中包含的版本不是您想要的版本，您可以使用 PostgreSQL Apt Repository。
此存储库将与您的常规系统和补丁管理集成，并在PostgreSQL 的整个支持生命周期内为所有受支持的 PostgreSQL 版本提供自动更新。
1. 执行以下命令安装 PostgreSQL
    ```
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql
    ```
2. 执行以下命令测试 PostgreSQL 是否安装成功
    `sudo -u postgres psql -c "SELECT version();"`
    出现如下信息则代表安装成功
    ![](/img/postgresql_1.png)
3. 修改配置
    找到/etc/postgresql/15/main/postgresql.conf文件，
    将`listen_addresses = 'localhost'`修改为`listen_addresses = '*'`。
    找到/etc/postgresql/15/main/pg_hba.conf文件，
    添加`host    all             all             0.0.0.0/0               scram-sha-256`。
    修改完成后执行`sudo service postgresql restart`。
4. 创建用户
    * 执行`sudo su - postgresql`切换到postgres用户
    * 执行`psql`命令登录。
5. 远程连接

### 源码编译安装

### Docker安装

### 配置

## 数据库优化

## 高可用方案