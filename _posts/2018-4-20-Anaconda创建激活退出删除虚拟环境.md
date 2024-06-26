---
layout:     post
title:      Anaconda创建、激活、退出、删除虚拟环境
subtitle:   在Anaconda中conda可以理解为一个工具，也是一个可执行命令，其核心功能是包管理与环境管理。所以对虚拟环境进行创建、删除等操作需要使用conda命令。
date:       2018-4-20
author:     呆贝斯
header-img: img/anaconda.png
tags:
    - Python
---
## 创建虚拟环境

使用命令`conda create -n your_env_name python=X.X`创建Python版本为X.X、名字为your_env_name的虚拟环境。
your_env_name文件可以在Anaconda安装目录envs文件下找到。在不指定python版本时，自动安装最新python版本。
注意：至少需要指定python版本或者要安装的包。

```bash
conda create -n your_env_name python=2.7  # 指定Python版本为2.7
conda create -n your_env_name numpy matplotlib python=2.7  # 指定Python版本为2.7，同时安装numpy、matplotlib包
```

## 激活虚拟环境

```bash
    conda activate your_env_name  # 激活指定名称虚拟环境
```

## 退出虚拟环境

```bash
    conda deactivate  # 退出当前虚拟环境
```

## 删除虚拟环境中包

```bash
    conda remove -n your_env_name package_name  # 删除指定名称虚拟环境中的指定包
```

## 删除虚拟环境

```bash
    conda remove -n your_env_name --all  # 删除指定名称虚拟环境
```

## conda常用命令

```bash
    conda list：查看安装了哪些包。
    conda install package_name(包名)：安装包
    conda env list 或 conda info -e：查看当前存在哪些虚拟环境
    conda update conda：检查更新当前conda
```
