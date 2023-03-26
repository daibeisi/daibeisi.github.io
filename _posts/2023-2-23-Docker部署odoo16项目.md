---
layout:     post
title:      Docker部署Odoo16项目
subtitle:   ...
date:       2023-2-23
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
---
# 准备工作
1. 创建一个如下目录文件夹。
   ```
   odoo16_addons
    ├── bin
    ├── local-addons             // 个人开发的插件
    ├── Dockerfile
    ├── docker-compose.yml
    ├── odoo.cfg                 // odoo项目配置文件
    ├── requirements.txt         // Python需求包
    └── README.md                // 项目文档
   ```

2. 在项目目录中创建一个Dockerfile文件,将以下内容添加到Dockerfile。
    ```
    # syntax=docker/dockerfile:1
    FROM odoo:16.0
    WORKDIR /mnt
    COPY ./requirements.txt /mnt/
    RUN pip install -r requirements.txt
    ```
    这个Dockerfile从Python3父图像开始。通过添加新code目录来修改父图像。
    通过安装requirements.txt文件中定义的 Python 要求进一步修改父映像。

3. 在项目目录中创建一个requirements.txt文件,并在文件中添加所需的软件。
    ```
    pyjwt==2.6.0
    ```
    此文件被Dockerfile中RUN pip install -r requirements.txt使用.

4. 在项目目录中创建一个名为docker-compose.yml的文件。

    该docker-compose.yml文件描述了制作您的应用程序的服务。
    在此示例中，这些服务是 Web 服务器和数据库。
    compose 文件还描述了这些服务使用哪些 Docker 映像、它们如何链接在一起、它们可能需要安装在容器内的任何卷。
    最后，该docker-compose.yml文件描述了这些服务公开的端口。
    ```
    version: '3'
    services:
      web:
        image: odoo:16.0
        restart: always
        container_name: odoo
        depends_on:
          - db
        ports:
          - "8069:8069"
        environment:
          - TZ=Asia/Shanghai
        volumes:
          - ./odoo-web-data:/var/lib/odoo
          - ./odoo-web-log:/var/log/odoo
          - ./config:/etc/odoo
          - ./extra-addons:/mnt/extra-addons
      db:
        image: postgres:14
        restart: always
        container_name: postgres
        environment:
          - TZ=Asia/Shanghai
          - POSTGRES_DB=odoo
          - POSTGRES_USER=odoo
          - POSTGRES_PASSWORD=odoo
        volumes:
          - ./odoo-db-data:/var/lib/postgresql/data
    ```

# 运行Odoo项目
1. 切换到项目目录的根目录。

2. 通过运行docker-compose run命令创建 Django 项目，如下所示。
    ```
    $ sudo docker-compose run web django-admin startproject composeexample .
    ```
    这指示 Compose使用服务的映像和配置django-admin startproject composeexample 在容器中运行。
    web由于web图像尚不存在，Compose 从当前目录构建它，如build: ..docker-compose.yml
    构建服务映像后web，Compose 将运行它并 django-admin startproject在容器中执行命令。
    此命令指示 Django 创建一组代表 Django 项目的文件和目录。

3. docker-compose命令完成后，执行`ls -l`命令列出项目的内容。

    如果您在 Linux 上运行 Docker，则django-admin创建的文件归 root 所有。
    发生这种情况是因为容器以 root 用户身份运行。
    如果您在 Mac 或 Windows 上运行 Docker，您应该已经拥有所有文件的所有权，包括由 django-admin。

4. 更改新文件的所有权。

    ```
    $ sudo chown -R $USER:$USER composeexample manage.py
    ```
    请勿更改 Postgres 文件所在的 data 文件夹的权限，否则 Postgres 将因权限问题无法启动。

# 连接数据库

1. 在您的项目目录中，编辑该composeexample/settings.py文件。

2. 替换以下内容。

    ```
    # settings.py
    
    import os
       
    [...]
    ALLOWED_HOSTS = ['*']
    [...]
    
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ.get('POSTGRES_NAME'),
            'USER': os.environ.get('POSTGRES_USER'),
            'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
            'HOST': 'db',
            'PORT': 5432,
        }
    }
    ```
    这些设置是由docker-compose.yml中指定的postgres Docker映像决定的。

3. 保存并关闭文件。

4. 从项目的顶级目录运行docker-compose up命令。

    ```
    $ docker-compose up
    ```
    此时，Django 应用程序应该在 Docker 主机上的`8000`端口上运行。
    在适用于 Mac 的 Docker Desktop 和适用于 Windows 的 Docker Desktop 上，
    Web 浏览器打开`http://localhost:8000`以查看 Django 欢迎页面。

5. 列出正在运行的容器。 

    在另一个终端窗口中使用`docker ps`或`docker container ls`命令列出正在运行的 Docker 进程。

6. 使用以下任一方法关闭服务并进行清理：
    1. 在与启动项目的相同终端窗口键入`Ctrl-C`来停止应用程序：
    2. 为了更优雅的关闭，切换到不同的终端窗口，然后在 Django 示例项目目录的顶层下运行`docker-compose down`。