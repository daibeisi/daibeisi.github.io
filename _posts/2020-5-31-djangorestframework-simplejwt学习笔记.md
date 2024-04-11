---
layout:     post
title:      djangorestframework-simplejwt学习笔记
subtitle:   ...
date:       2022-5-31
author:     呆贝斯
header-img: img/post-bg-desk.jpg
tags:
    - Python
---
## 简介

Django REST框架的JSON Web Token认证插件。

## 安装

```bash
pip install djangorestframework-simplejwt
```

如打算使用数字签名算法对令牌进行编码或解码，需要额外安装`djangorestframework-simplejwt[crypto]`。

## 项目配置

1. Django项目需要配置使用该库，添加 rest_framework_simplejwt.authentication.JWTAuthentication到身份验证类列表。

    ```python
    REST_FRAMEWORK = {
        ...
        'DEFAULT_AUTHENTICATION_CLASSES': (
            ...
            'rest_framework_simplejwt.authentication.JWTAuthentication',
        )
        ...
    }
    ```

2. 添加获取token和刷新token接口到项目urls.py。

    ```python
    from rest_framework_simplejwt.views import (
        TokenObtainPairView,
        TokenRefreshView,
    )
    
    urlpatterns = [
        ...
        path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
        ...
    ]
    ```

3. 配置SIMPLE_JWT，添加到settings.py。

   ```python
   SIMPLE_JWT = {
       "ACCESS_TOKEN_LIFETIME": timedelta(hours=2),  # 访问令牌有效时间
       "REFRESH_TOKEN_LIFETIME": timedelta(days=7),  # 刷新令牌有效时间
       "ROTATE_REFRESH_TOKENS": True,  # 若为True，刷新时refresh_token也会刷新
       "BLACKLIST_AFTER_ROTATION": True,  # 若为True，刷新后的token将添加到黑名单中
       "UPDATE_LAST_LOGIN": False,  # 是否更新auth_user 表中的 last_login 字段
       "ALGORITHM": "HS256",  # 加密算法
       "SIGNING_KEY": SECRET_KEY,  # 签名密钥
       "VERIFYING_KEY": "",  # 验证密钥，加密算法指定HMAC时被忽略
       "AUDIENCE": None,  # 生成的令牌中和/或在解码的令牌中验证的受众主张。当设置为 "无 "时，该字段被排除在令牌之外，并且不被验证。
       "ISSUER": None,  # 生成的令牌中和/或在解码的令牌中验证的发行者主张。当设置为 "无 "时，该字段被排除在令牌之外，并且不被验证。
       "JSON_ENCODER": None,
       "JWK_URL": None,  # JWK_URL用于动态解析验证令牌签名所需的公钥
       "LEEWAY": timedelta(seconds=60),  # 令牌过期回旋时间
       "AUTH_HEADER_TYPES": ("Bearer",),  # 需要认证的视图所接受的授权头类型
       "AUTH_HEADER_NAME": "HTTP_AUTHORIZATION",  # 用于认证的授权标头名称
       "USER_ID_FIELD": "id",  # 指定识别用户的字段
       "USER_ID_CLAIM": "user_id",  # 存储用户标识符
   
       # 确定用户是否被允许进行认证规则
       "USER_AUTHENTICATION_RULE": "rest_framework_simplejwt.authentication.default_user_authentication_rule",
   
       "AUTH_TOKEN_CLASSES": (
           "rest_framework_simplejwt.tokens.AccessToken",
           # "rest_framework_simplejwt.tokens.SlidingToken"
       ),  # 允许用来证明认证的令牌类型
       "TOKEN_TYPE_CLAIM": "token_type",  # 存储令牌类型的名称
   
       # 一个无状态的用户对象，由一个经过验证的令牌支持。仅用于JWTStatelessUserAuthentication认证后端。
       "TOKEN_USER_CLASS": "rest_framework_simplejwt.models.TokenUser",
   
       "JTI_CLAIM": "jti",  # 存储一个令牌的唯一标识符的声称名称
   
       "SLIDING_TOKEN_REFRESH_EXP_CLAIM": "refresh_exp",  # 存储滑动令牌刷新期的过期时间的名称
       "SLIDING_TOKEN_LIFETIME": timedelta(minutes=5),  # 滑动令牌的有效时间
       "SLIDING_TOKEN_REFRESH_LIFETIME": timedelta(days=1),  # 指定了可以刷新滑动令牌的有效时间
   
       "TOKEN_OBTAIN_SERIALIZER": "rest_framework_simplejwt.serializers.TokenObtainPairSerializer",
       "TOKEN_REFRESH_SERIALIZER": "rest_framework_simplejwt.serializers.TokenRefreshSerializer",
       "TOKEN_VERIFY_SERIALIZER": "rest_framework_simplejwt.serializers.TokenVerifySerializer",
       "TOKEN_BLACKLIST_SERIALIZER": "rest_framework_simplejwt.serializers.TokenBlacklistSerializer",
       "SLIDING_TOKEN_OBTAIN_SERIALIZER": "rest_framework_simplejwt.serializers.TokenObtainSlidingSerializer",
       "SLIDING_TOKEN_REFRESH_SERIALIZER": "rest_framework_simplejwt.serializers.TokenRefreshSlidingSerializer",
   }
   ```

4. 如果允许用户在无需访问签名密钥情况下验证HMAC签名的令牌，需要添加认证接口。

   ```python
   from rest_framework_simplejwt.views import TokenVerifyView
   
   urlpatterns = [
       ...
       path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
       ...
   ]
   ```

5. 如果你希望使用本地化或翻译，需要添加`rest_framework_jwt`到`INSTALLED_APPS`。

   ```python
   INSTALLED_APPS = [
       ...
       'rest_framework_simplejwt',
       ...
   ]
   ```

## 测试

1. 发送测试请求。

   ```bash
   curl \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"username": "davidattenborough", "password": "boatymcboatface"}' \
     http://localhost:8000/api/token/
   
   ...
   {
     "access":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3BrIjoxLCJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiY29sZF9zdHVmZiI6IuKYgyIsImV4cCI6MTIzNDU2LCJqdGkiOiJmZDJmOWQ1ZTFhN2M0MmU4OTQ5MzVlMzYyYmNhOGJjYSJ9.NHlztMGER7UADHZJlxNG0WSi22a2KaYSfd1S-AuT7lU",
     "refresh":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3BrIjoxLCJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImNvbGRfc3R1ZmYiOiLimIMiLCJleHAiOjIzNDU2NywianRpIjoiZGUxMmY0ZTY3MDY4NDI3ODg5ZjE1YWMyNzcwZGEwNTEifQ.aEoAYkSJjoWH1boshQAaTkf8G3yn0kapko6HFRt7Rh4"
   }
   ```

2. 使用access访问受保护的视图。

   ```bash
   curl \
     -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3BrIjoxLCJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiY29sZF9zdHVmZiI6IuKYgyIsImV4cCI6MTIzNDU2LCJqdGkiOiJmZDJmOWQ1ZTFhN2M0MmU4OTQ5MzVlMzYyYmNhOGJjYSJ9.NHlztMGER7UADHZJlxNG0WSi22a2KaYSfd1S-AuT7lU" \
     http://localhost:8000/api/some-protected-view/
   ```

3. 当access过期时，使用refresh来获取另一个access。

   ```bash
   curl \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"refresh":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3BrIjoxLCJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImNvbGRfc3R1ZmYiOiLimIMiLCJleHAiOjIzNDU2NywianRpIjoiZGUxMmY0ZTY3MDY4NDI3ODg5ZjE1YWMyNzcwZGEwNTEifQ.aEoAYkSJjoWH1boshQAaTkf8G3yn0kapko6HFRt7Rh4"}' \
     http://localhost:8000/api/token/refresh/
   
   ...
   {"access":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3BrIjoxLCJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiY29sZF9zdHVmZiI6IuKYgyIsImV4cCI6MTIzNTY3LCJqdGkiOiJjNzE4ZTVkNjgzZWQ0NTQyYTU0NWJkM2VmMGI0ZGQ0ZSJ9.ekxRxgb9OKmHkfy-zs1Ro_xs1eMLXiR17dIDBVxeT-w"}
   ```

## 自定义令牌声明

## 手动创建令牌

如果需要为用户手动创建令牌，可按如下方式完成。

```python
from rest_framework_simplejwt.tokens import RefreshToken

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)

    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }
```

上面的函数get_tokens_for_user将返回给定用户的新刷新和访问令牌的序列化表示。
一般来说，任何 rest_framework_simplejwt.tokens.Token 子类的令牌都可以通过这种方式创建。

## 令牌类型

simplejwt提供了两种不同的令牌类型用于认证。令牌的类型通过令牌载荷中

### 滑动令牌

## 黑名单应用

## 无状态用户认证

JwtStatelessUserAuthentication后端认证方法并不执行数据库查询来获得一个数据库实例，相反，它返回一个
rest_framework_simplejwt.models.TokenUser实例，作为一个无状态用户对象，只由一个经过验证的令牌支持，而不是数据库中的记录。他可以开发单独托管的Django应用程序之间的单点登录功能，这些应用程序都共享相同的令牌密钥。要使用这个功能，需要在DjangoREST框架中的DEFAULT_AUTHENTICATION_CLASSES配置设置中添加rest_framework_simplejwt.authentication
