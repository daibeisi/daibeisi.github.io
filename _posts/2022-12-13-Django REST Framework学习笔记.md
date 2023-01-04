---
layout:     post
title:      Django REST Framework 学习笔记
subtitle:   ...
date:       2022-12-13
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - Django REST Framework
---
# 介绍
DRF是一个强大灵活的Django工具包，用于在Web后台构建Restful接口。
* 你可以在一个Web页面上浏览自己提供了哪些API，并且可以通过这个页面测试这些API
* 你不用自己写一套接口鉴权代码了,提供了各种开箱即用的API认证授权工具，如OAuth2
* 你不用自己写大量的CRUD接口了，简单配置即可
* 你不用自己写大量的条件查询接口了，简单配置即可
* 你不用自己写后台分页逻辑了，简单配置即可
* 你不用自己写接口限流逻辑了，简单配置即可
* 你不用自己写各种简单的参数校验逻辑了，简单配置即可
* 你不用自己注册各种路由了，简单配置即可
* 你的权限控制逻辑不用写到业务逻辑中了
* 提供了orm数据序和非orm数据的序列化支持
* 大量的文档和社区支持

# 安装
1. pip安装相关包
    ```
    pip install djangorestframework
    pip install markdown       # 为browsable API 提供Markdown支持。
    pip install django-filter  # Filtering支持。
    ```
2. 在INSTALLED_APPS中添加 'rest_framework' 项。
    ```
    INSTALLED_APPS = [
       ...
       'rest_framework',
    ]
    ```
3. 打算用browsable API，可能也想用REST framework的登录注销视图。把下面的代码添加到你根目录的urls.py文件。
    ```
    urlpatterns = [
        ...
        path('api-auth/', include('rest_framework.urls'))
    ]
    ```

# 快速开始
# ...