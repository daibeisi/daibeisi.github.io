---
layout:     post
title:      Wsgi VS Asgi
subtitle:   ...
date:       2023-2-15
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
---
# Wsgi
Wsgi是同步通信服务规范，调用方请求一项服务，并等待服务完成，只有
调用方收到服务的结果时，它才会继续工作。调用方也可以定义一个超时时间，
如果服务在规定的时间内没有完成则认为调用失败，调用方继续工作。

# Asgi
Asgi是异步通讯服务规范，调用方请求一项服务，但不等待结果，调用立即继续其它工作，并不关心之前的结果。
如果调用方对结果感兴趣，有一些机制可以让其随时被回调方法返回结果。

# 总结