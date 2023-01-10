---
layout:     post
title:      Access Token 与 Refresh Token 详解以及使用原则
subtitle:   分析Access Token 和 Refresh Token 的配合流程和安全要点，得到正确管理和使用Access Token 和 Refresh Token的方法和原则。
date:       2022-4-26
author:     呆贝斯
header-img: img/post-bg-hacker.jpg
onTop: true
catalog: true
tags:
    - Oauth2
    - Access Token & Refresh Token
---
## Oauth2 使用Token的基本流程
我们先看看一个来自RFC6749定义的Oauth2中token使用的基本流程，大概可以明白Access Token和Refresh Token两个的用法。
```
  +--------+                                           +---------------+
  |        |--(A)------- Authorization Grant --------->|               |
  |        |                                           |               |
  |        |<-(B)----------- Access Token -------------|               |
  |        |               & Refresh Token             |               |
  |        |                                           |               |
  |        |                            +----------+   |               |
  |        |--(C)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(D)- Protected Resource --| Resource |   | Authorization |
  | Client |                            |  Server  |   |     Server    |
  |        |--(E)---- Access Token ---->|          |   |               |
  |        |                            |          |   |               |
  |        |<-(F)- Invalid Token Error -|          |   |               |
  |        |                            +----------+   |               |
  |        |                                           |               |
  |        |--(G)----------- Refresh Token ----------->|               |
  |        |                                           |               |
  |        |<-(H)----------- Access Token -------------|               |
  +--------+           & Optional Refresh Token        +---------------+
               Figure 2: Refreshing an Expired Access Token

```
上图中Authorization Server翻译为授权服务，负责Token的签发。Resource Server翻译为资源服务，
也就是被授权访问的资源，比如API接口。在分布式应用中，他们应该分属不同的服务。
值得注意的是，资源服务器不签发Token，但是可以具备独立验证Access Token的能力。

上面的流程图包括了下面的步骤。

+ (A) 客户端向授权服务器请求Access Token（整个认证授权的流程，可以是多次请求完成该步骤）
+ (B) 授权服务器验证客户端身份无误，且请求的资源是合理的，则颁发Access Token 和 Refresh Token，可以同时返回Access Token的过期时间等附加属性。
+ (C) 带着Access Token请求资源
+ (D) 资源服务器验证Access Token有效则返回请求的内容。
+ (E) 注意： 上面的(C)(D)步骤可以反复进行，直到Access Token过期。 如果客户端在请求之前就能判断Access Token已过期或临近过期（下发过期时间），就可以直接跳到步骤(G)。否则，就会再请求一次，也就产生了本步骤。
+ (F) 当Access Token无效的时候，资源服务器会拒绝响应资源并返回Token无效的错误。
+ (G) 客户端重新向授权服务器请求Access Token，但是这次只需带着Refresh Token即可，而不需要用户再执行认证和授权的流程。这样就可以做到用户无感。
+ (H) 授权服务器验证Refresh Token，如果有效，则签发新的Access Token（或者同时下发一个新的Refresh Token）。

我们总结几个点，Access Token作为请求资源的凭证，是使用最频繁的，但是有效期比较短，
Refresh Token有效期较长，只会发给授权服务器，用来获取新的Access Token。
## 资源服务如何脱离授权服务验证Access Token？
以JTW为例。如果Access Token是JWT形式签发，资源服务可以使用验证签名的方式判断是否合法，
只需要把签名密钥在资源服务同步一份即可。也有使用非对称加密的，授权服务使用私钥签发，
资源服务使用公钥验证。由于JWT允许携带一些信息，用户，权限，有效期等，
因此资源服务判断JWT合法之后可以继续根据携带信息来判断是否可访问资源。
仅此而已，这样的好处是可以快速验证有效性，坏处是Access Token一旦签发，将很难收回，只能通过过期来失效。
## Refresh Token机制如何提升安全？
Refresh Token的其中一个目的是让用户在较长的时间保持登录状态，那么可否直接让Access Token具有更长的有效期，从而可以省去许多没用的步骤。答案是不安全，理由参考上面问题的答案。
举个例子，某个用户登录成功，获得了一个可以发帖的Access Token，这时管理员发现他发布垃圾内容吊销了发帖权限，而这个信息一般属于授权服务管理，也就是说他下次向授权服务请求Access Token将不会得到发帖权限。但是如果用户之前拿到的Access Token是长期有效的，那么这个用户就可以发帖很长时间。如果Access Token在短时间内失效，那么他必须重新去授权服务请求，这时授权服务将不会颁发具备发帖权限的Access Token。
第二个例子，如果Access Token具有较长的有效期，一旦被盗用，攻击者就可以拿Access Token使用很长时间。聪明的你可能会想到，攻击者可以同时盗取Refresh Token。
RFC6749第10节中有说明，授权服务必须维护Refresh Token与客户端的绑定关系，也就是说只有合法用户的客户端（可通过IP,UA等资料判断）来请求是可以通过的。退一步讲，如果攻击者模拟了客户端可以执行刷新请求，那么就要看谁先刷。由于授权服务可以设置Refresh Token一次有效，因此不管哪个先刷新，另一个人刷新就会报错。如果用户先刷新，攻击者以Access Token和Refresh Token的双重失效结束游戏。如果攻击者先刷新了，合法用户就会收到报错信息，授权服务会引导用户从上图的步骤(A)重新开始认证，从而把有效的Refresh Token拿回到合法用户这里。
## 总结
Access Token应该维持在较短有效期，过长不安全，过短也会影响用户体验，因为频繁去刷新带来没有必要的网络请求。可以参考我们常常在某些网站停止操作一段时间之后就会掉线，这个时间是Refresh Token的有效期，Access Token不应长过这个时间。
Refresh Token的有效期就是允许用户在多久时间内不用重新登录的时间，可以很长，视业务而定。我们在使用某些APP的时候，即使一个月没有开过也是登录状态的，这就是Refresh Token决定的。授权服务在接到Refresh Token的时候还要进一步做客户端的验证，尽可能排除盗用的情况。
所有token应该保管在private的地方，也就是只能客户端自己使用，所有token都应该在TLS信道下发送（比如HTTPS）。
## 参考
[西门老铁](https://juejin.cn/post/6859572307505971213)

[The OAuth 2.0 Authorization Framework](http://www.rfcreader.com/#rfc6749_line2308)

