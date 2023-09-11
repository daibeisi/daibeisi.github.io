---
layout:     post
title:      Postgresql找出慢SQL
date:       2023-9-11
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
catalog: true
tags:
    - 数据库
---
# 找出慢SQL
## 使用 pg_stat_statements 插件
1. 可以通过修改 PostgreSQL 配置文件（通常是 postgresql.conf）设置`shared_preload_libraries = 'pg_stat_statements'`
并重新启动 PostgreSQL 服务来启用它（最好在数据库创建之初就把插件配置上），
如果需要把执行操作超一定时间的SQL语句打印到日志中，可以在配置文件中设置`log_min_duration_statement = 10000`。
2. 登录数据库执行`create extension pg_stat_statements;`命令来启用。
3. 上面步骤完成后数据库会出现名称为 pg_stat_statements 的视图，视图内有SQL语句执行信息。

可通过以下语句找出想要的结果：
* 找出执行时间最长的10条SQL语句：`select total_exec_time, query from pg_stat_statements order by total_exec_time desc limit 10;`
* 找出执行最频繁的SQL语句：`select calls, query from pg_stat_statements order by calls desc limit 10;`

## 使用 auto_explain 插件

## 使用 pgBadger 或其他日志分析工具

## 使用监控工具

# 分析慢SQL
## 使用 EXPLAIN 分析

# 优化慢SQL
## 优化SQL语句技巧
1. 尽量避免全表扫描和排序操作，考虑在查询条件的列和 ORDER BY 涉及的列上建立索引。
2. 经常进行的范围查询考虑使用`CLUSTER table_name USING index_name`让表中行的物理存储顺序与索引的顺序一致，以提高查询效率。
3. 避免在WHERE子句中对字段进行函数或表达式操作，这会导致走不到索引。
4. 

## 优化方法
1. 使用索引
2. 避免全表扫描