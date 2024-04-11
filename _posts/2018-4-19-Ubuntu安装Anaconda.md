---
layout:     post
title:      Ubuntu安装与卸载Anaconda
date:       2018-4-19
author:   呆贝斯
header-img: img/anaconda.png
tags:
    - Python
---
## 安装

1. 到 [Anaconda官网](https://www.anaconda.com/distribution/) 或 [miniconda](https://docs.conda.io/en/latest/miniconda.html) 找到对应安装包链接使用wget下载。

2. cd到服务器上安装包所在位置，用以下命令安装(不建议使用root账户安装)。

    ```text
    bash Anaconda3-*-Linux-x86_64.sh
    ```

3. 点击`Enter`，直到出现。

    ![Anaconda_install_1](/img/Anaconda_install_1.png)

4. 输入`yes`,出现下图。

    ![Anaconda_install_2](/img/Anaconda_install_2.png)

5. 点击`Enter`表示在默认位置安装，按`Ctrl+C`放弃安装，或者之当一个不同位置，这里直接默认，等待安装完成。

    ![Anaconda_install_3](/img/Anaconda_install_3.png)

6. 出现下图表示安装完成，输入`yes`进行初始化。

    ![Anaconda_install_5](/img/Anaconda_install_5.png)

7. 初始化完成后需要打开新的终端才能生效，如果不想默认激活`base`环境，可输入命令`conda config --set auto_activate_base false`关闭 ，最后输入`conda --version`检测是否安装功。

    ![Anaconda_install_5](/img/Anaconda_install_5.png)

8. win10安装时勾选把conda添加到系统环境变量，安装完成后以管理员身份运行 power shell 并执行以下命令。

    ```text
    set-ExecutionPolicy RemoteSigned
    conda init powershell
    ```

## 卸载

1. 由于Anaconda的安装文件都包含在一个目录中，所以直接将该目录删除即可。到Anaconda安装目录，删除整个Anaconda目录。

2. 到安装Anaconda的用户目录下执行`ls -a`查看文件，删除`.conda .condarc`等Anaconda相关文件，并编辑目录下`.bashrc`，删除下图代码，保存并关闭文件。

    ![Anaconda_delete_1](/img/Anaconda_delete_1.png)

3. 在终端执行如下命令，使其立即生效。

    ```text
    source ~/.bashrc
    ```
