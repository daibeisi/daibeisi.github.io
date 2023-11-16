---
layout:     post
title:      Docker搭建PostgreSQL一主二从架构
date:       2023-9-11
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
catalog: true
tags:
    - 数据库
---
## 前提条件

3台服务器并安装Docker

## 配置PostgreSQL主节点

1. 远程连接PostgreSQL主节点，依次运行以下命令，安装PostgreSQL。
    1. 输入`mkdir postgresql`命令，创建postgresql文件夹。
    2. 输入`cd postgresql`命令，进入postgresql文件夹。
    3. 输入`vim docker-compose.yml`命令，并将以下内容写入，创建docker-compose.yml文件。

        ```yml
        version: '3.1'
        services:
          postgres:
            image: postgres:16.1
              container_name: postgresql
              restart: always
              environment:
                - POSTGRES_DB=postgres
                - POSTGRES_USER=postgres
                - POSTGRES_PASSWORD=<数据库密码>
                - TZ=Asia/Shanghai
              volumes:
                - ./data/:/var/lib/postgresql/data
              ports:
                - "5432:5432"
        ```

    4. 输入`docker-compose up -d`命令，启动PostgreSQL。

2. 在主节点上创建数据库账号replica（用于主从复制），并设置密码及登录权限和备份权限。
    1. 输入命令`docker exec -it postgresql bash`，进入postgresql容器。
    2. 输入命令`su - postgres`，登录postgres用户。
    3. 输入`psql`命令进入PostgreSQL交互终端，当显示postgres=#时表示成功进入交互终端。
    4. 输入以下SQL语句创建数据库账号replica，并设置密码及登录权限和备份权限。

        ```SQL
        CREATE ROLE replica login replication encrypted password '<备份账户密码>';
        ```

    5. 输入以下SQL语句查询账号是否创建成功。返回记录包含replica，表示已创建成功。

        ```SQL
        SELECT usename from pg_user;
        ```

    6. 终端输入`\q`，退出SQL终端。输入`exit`命令，退出postgres用户，再输入`exit`命令，退出容器。

3. 修改创建的postgresql文件夹下data文件中pg_hba.conf文件，检查并设置replica用户白名单，允许从节点密码认证连接和允许用户从replication数据库进行数据同步。

    ```conf
    host    all             all             all                     scram-sha-256  #允许VPC网段中md5密码认证连接
    host    replication     all             all                     scram-sha-256  #允许用户从replication数据库进行同步
    ```

4. 修改创建的postgresql文件夹下data文件中postgresql.conf文件，分别找到以下参数，并将参数修改为以下内容。

    ```conf
    listen_addresses = '*'   #监听的IP地址
    wal_level = replica      #启用热备模式
    max_wal_senders = 10     #同步最大的进程数量
    wal_sender_timeout = 60s #流复制主机发送数据的超时时间
    max_connections = 100    #最大连接数，从库的max_connections必须要大于主库的
    # 注意，如果配置同步复制，建议是一主二从，防止从库同步异常导致主库hang住。
    synchronous_commit = on  #开启同步复制
    synchronous_standby_names = 'ANY 1 (slave1, slave2)' 
    #只要primary端wal传到任意一台standby并commit就OK，这里填写的是备库primary_conninfo中application_name参数值。
    ```

5. 运行`docker restart postgresql`命令，重启服务。

## 配置PostgreSQL从节点

1. 远程连接PostgreSQL从节点1，同上PostgreSQL主节点安装操作，安装PostgreSQL。

2. 使用pg_basebackup基础备份工具指定备份目录（注意：备份后主节点不可进行任何操作，直到验证从节点正常才可操作主节点）。
    1. 输入命令`docker exec -it postgresql bash`，进入postgresql容器。
    2. 进入 /var/lib/postgresql/data 目录，在目录下创建 data_new 文件夹
    3. 运行以下命令，使用pg_basebackup基础备份工具指定备份目录。

        ```bash
        pg_basebackup -h <主节点ip> -p 5432 -U replica -D <保存路径> -X stream -P -R
        ```

        注意：-R选项用于创建用于replication的配置文件，生成$PGDATA/standby.signal文件，该文件必须存在，用来标识这是一个备库。

    4. 输入`exit`命令，退出容器。

3. 修改创建的postgresql文件夹下data文件夹下data_new文件夹中postgresql.conf文件，分别找到以下参数，并将参数修改为以下内容。

    ```conf
    recovery_target_timeline = 'latest' #流复制同步到最新的数据
    max_connections = 1000             # 最大连接数，从节点需设置比主节点大
    hot_standby = on                   # 开启热备
    max_standby_streaming_delay = 30s  # 数据流备份的最大延迟时间
    wal_receiver_status_interval = 1s  # 从节点向主节点报告自身状态的最长间隔时间
    hot_standby_feedback = on          # 如果有错误的数据复制向主进行反馈
    ```

4. 修改创建的postgresql文件夹下data文件夹下data_new文件夹中postgresql.auto.conf文件，在 primary_conninfo 参数配置添加`application_name=slave1`。

    ```conf
    primary_conninfo = '******** application_name=slave1'
    ```

5. 输入命令，将data_new文件夹中内容替换创建的postgresql文件夹下data文件夹内容。

6. 运行`docker restart postgresql`命令，重启服务。

7. 远程连接PostgreSQL从节点2，重复从节点1操作（将slave1改为slave2）。

## 检测验证

在主节点中进入PostgreSQL交互终端，输入以下SQL语句，在主库中查看从库状态。

1. 运行以下命令，登录postgres用户。

    ```bash
    su - postgres
    ```

2. 输入`psql`命令进入PostgreSQL交互终端，当显示postgres=#时表示成功进入交互终端。
3. 运行以下命令，在主库中查看从库状态，返回结果如下图，表示可成功查看到从库状态。

    ```SQL
    select * from pg_stat_replication;
    ```

    ![一主二从pg_stat_replication](/img/1master_2slave_pg_stat_replication.png)

4. 终端输入`\q`，并按Enter退出SQL终端。输入`exit`命令，并按Enter退出PostgreSQL。
