---
layout:     post
title:      Docker Compose 搭建 Django 示例项目
subtitle:   ......
date:       2022-5-18
author:     呆贝斯
header-img: img/post-bg-desk.jpg
onTop: true
catalog: true
tags:
    - Docker Compose
    - Django
    - PostgreSQL
---
# 准备工作
1. 创建一个空的项目目录。

    可以将目录命名为易于记忆的名称。此目录是应用程序映像的上下文。该目录应该只包含构建该图像的资源。

2. 在项目目录中创建一个名为Dockerfile的新文件。

    Dockerfile 通过一个或多个配置该映像的构建命令定义应用程序的映像内容。构建后，您可以在容器中运行映像。

3. 将以下内容添加到Dockerfile。

    ```
    # syntax=docker/dockerfile:1
    FROM python:3
    ENV PYTHONDONTWRITEBYTECODE=1
    ENV PYTHONUNBUFFERED=1
    WORKDIR /code
    COPY requirements.txt /code/
    RUN pip install -r requirements.txt
    COPY . /code/
    ```
    这个Dockerfile从Python3父图像开始。通过添加新code目录来修改父图像。通过安装requirements.txt文件中定义的 Python 要求进一步修改父映像。

4. 保存并关闭Dockerfile。

5. 在项目目录中创建一个requirements.txt文件。

    此文件被Dockerfile中RUN pip install -r requirements.txt使用.

6. 在文件中添加所需的软件。

    ```
    Django>=3.0,<4.0
    psycopg2>=2.8
    ```

7. 保存并关闭requirements.txt文件。

8. 在项目目录中创建一个名为docker-compose.yml的文件。

    该docker-compose.yml文件描述了制作您的应用程序的服务。
    在此示例中，这些服务是 Web 服务器和数据库。
    compose 文件还描述了这些服务使用哪些 Docker 映像、它们如何链接在一起、它们可能需要安装在容器内的任何卷。
    最后，该docker-compose.yml文件描述了这些服务公开的端口。

9. 将以下配置添加到文件中。

    ```
    version: "3.9"
       
    services:
      db:
        image: postgres
        volumes:
          - ./data/db:/var/lib/postgresql/data
        environment:
          - POSTGRES_DB=postgres
          - POSTGRES_USER=postgres
          - POSTGRES_PASSWORD=postgres
      web:
        build: .
        command: python manage.py runserver 0.0.0.0:8000
        volumes:
          - .:/code
        ports:
          - "8000:8000"
        environment:
          - POSTGRES_NAME=postgres
          - POSTGRES_USER=postgres
          - POSTGRES_PASSWORD=postgres
        depends_on:
          - db
    ```
    该文件定义了两个服务：db服务和web服务。
    这里使用内置开发服务器在端口`8000`上运行应用程序，不要在生产环境中使用它。

10. 保存并关闭docker-compose.yml文件。

# 创建Django项目
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
