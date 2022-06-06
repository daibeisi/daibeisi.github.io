---
layout:     post
title:      Python操作Redis
subtitle:   ......
date:       2022-4-28
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - Python
    - Redis
---
# Redis数据库基础
1. Redis数据库介绍
    + `用途`：数据库、缓存和消息中间件
    + `类型`：
        1. 字符串（strings）
        2. 散列（hashes）
        3. 列表（lists）
        4. 集合（sets）
        5. 有序集合（sorted sets）

2. 安装及配置

   `官网`：https://redis.io/

3. Redis常用操作
    + `字符串相关操作`
        + set -- 设置值
        + get -- 获取值
        + mset -- 设置多个键值对
        + mget -- 获取多个键值对
        + append -- 添加字符串
        + del -- 删除
        + incr/decr -- 增加/减少1
    + `列表相关操作`
        + lpush/rpush  -- 从左/右添加数据
        + lrange -- 获取指定长度信息
        + ltrim -- 截取指定长度信息
        + llen -- 获取长度
        + lpop/rpop -- 移除最左或右数据
        + lpushx/rpushx -- key存在才会加入数据，不存在不会做任何事情
    + `集合相关操作`
        + sadd/srem -- 添加/删除元素
        + sismember -- 判断是否为set的一个元素
        + smembers -- 返回该集合的所有成员
        + sdiff -- 返回一个集合和其他集合的差异
        + sinter -- 返回几个集合的交集
        + sunion -- 返回几个集合的并集
    + `散列相关操作`
        + hset/hget -- 设置/获取散列值
        + hmset/hmget -- 设置/获取多对散列值
        + hsetx -- 如果散列已经存在，则不设置
        + hkeys/hvals -- 返回所有Keys/Values
        + hlen -- 返回散列包含域（field）的数量
        + hdel -- 删除散列指定域（field）
        + hexists -- 判断是否存在
