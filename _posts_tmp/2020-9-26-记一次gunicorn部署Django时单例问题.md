---
layout:     post
title:      记一次gunicorn（开启多核）运行 Django 时单例不生效问题
subtitle:   ...
date:       2020-9-26
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - 随笔
    - Django
---

## 问题描述

Django 接口开发，业务逻辑中用到一个单例类，本地运行命令 `python manage.py runserver` 测试时接口运行正常，线上使用 gunicorn 运行  Django ，部署到线上后发现接口时好时坏。查看日志发现请求落到特定进程上接口返回正常，其他进程处理则报错。

## 思考

## 解决方案
