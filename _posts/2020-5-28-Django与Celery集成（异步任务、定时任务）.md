---
layout:     post
title:      Django日志学习笔记
subtitle:   ......
date:       2022-5-23
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - Django
---
# 什么是Celery？
一个分布式的任务队列，具有以下特点：
* 简单：几行代码可以创建一个简单的Celery任务
* 高可用：工作机会自动重试
* 快速：可以执行一分钟上百万任务
* 灵活：每一块都可以扩展

# 使用场景
* 发送电子邮件、发送IM消息通知
* 爬取网页、数据分析
* 图像、视频处理
* 生成报告，深度学习
![](/img/django-celery-example.png)

# 安装
```
pip install -U Celery
pip install "celery[redis,auth,msgpack]"
```


