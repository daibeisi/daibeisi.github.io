---
layout:     post
title:      Django REST Framework 学习笔记
subtitle:   ...
date:       2022-12-13
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - Django
---
## 介绍

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

## 项目为什么要引入drf呢？

先说结论，小项目（几个简单的接口和页面），用Django的FBV就行了，简单明了；中大型项目建议使用drf，效率和规范性更高。
小项目开发，设计好Model后，在views中编写视图函数，再在urls定义路由，一个接口就出来了，不过视图函数逻辑难免写成如下图逻辑。
![drf_1](/img/drf_1.png)
校验逻辑和业务功能很容易耦合到一起，视图函数也很容易被“搞大”，很容易出现重复代码多，函数过长，不好维护等问题。除此之外，
接口地址的命名，接口返回格式等都需要额外规范来统一。
![drf_2](/img/drf_2.png)
再来看这张图，借助DRF，我们可以将接口的开发过程规范化，形成一个统一的代码工作流：Serializers负责数据的序列化和反序列化，结合Validators可以低成本的实现参数校验、Permissions负责权限校验、Routers负责路由自动注册、通过重写框架定义的函数，还可以统一接口返回格式及异常处理等。简而言之，就是DRF为我们定义好了在什么位置写什么代码，开发都按照这个规范来写，接口才能正常工作。
通过Django+DRF，我们还可以很快速的配置出一套Django模型的CRUD接口，将一些开发工作变成配置工作，借助一些DRF周边工具，如django_filters，可以快速实现模型数据的过滤类接口，降低了开发成本，并保证接口规范统一。
其次，我们重用DRF的另一个原因是项目分工的精细化，通过引入前端团队，将原来的模板直出的方式优化为前后台分离，页面渲染的数据都通过Restful接口来提供，前端工程化，后端服务化，代码解耦，开发效率更高。

## 安装

1. pip安装相关包

    ```bash
    pip install djangorestframework
    pip install markdown                  # 为browsable API 提供Markdown支持。
    pip install django-filter             # Filtering支持。
    pip install PyYAML uritemplate        # Schema生成支持。
    pip install Pygments                  # 为Markdown处理提供语法高亮。
    pip install django-guardian           # 对象级别的权限支持。
    ```

2. 在INSTALLED_APPS中添加 'rest_framework' 项。

    ```python
    INSTALLED_APPS = [
       ...
       'rest_framework',
    ]
    ```

3. 打算用browsable API，可能也想用REST framework的登录注销视图。把下面的代码添加到你根目录的urls.py文件。

    ```python
    urlpatterns = [
        ...
        path('api-auth/', include('rest_framework.urls'))
    ]
    ```

## 快速开始

### 定义序列化程序

首先我们要定义一些序列化程序。我们创建一个名为 tutorial/quickstart/serializers.py的文件，来用作我们的数据表示。
请注意，在这个例子中我们用到了超链接关系，使用 HyperlinkedModelSerializer。你还可以使用主键和各种其他关系，但超链接是好的RESTful设计。

```python
from django.contrib.auth.models import User, Group
from rest_framework import serializers


class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'username', 'email', 'groups')


class GroupSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Group
        fields = ('url', 'name')
```

### 写一些视图函数

接下来再写一些视图。打开 tutorial/quickstart/views.py 文件开始写代码了。不再写多个视图，
我们将所有常见行为分组写到叫 ViewSets 的类中。如果我们需要，我们可以轻松地将这些细节分解为单个视图，
但是使用viewsets可以使视图逻辑组织良好，并且非常简洁。

```python
from django.contrib.auth.models import User, Group
from rest_framework import viewsets
from tutorial.quickstart.serializers import UserSerializer, GroupSerializer


class UserViewSet(viewsets.ModelViewSet):
    """
    允许用户查看或编辑的API路径。
    """
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserSerializer


class GroupViewSet(viewsets.ModelViewSet):
    """
    允许组查看或编辑的API路径。
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
```

### 定义url

现在在tutorial/urls.py中开始写连接API的URLs。因为我们使用的是viewsets而不是views，
所以我们可以通过简单地使用路由器类注册视图来自动生成API的URL conf。再次，如果我们需要对API URL进行更多的控制，
我们可以简单地将其拉出来使用常规基于类的视图，并明确地编写URL conf。
最后，我们将包括用于支持浏览器浏览的API的默认登录和注销视图。这是可选的，但如果您的API需要身份验证，
并且你想要使用支持浏览器浏览的API，那么它们很有用。

```python
from django.conf.urls import url, include
from rest_framework import routers
from tutorial.quickstart import views

router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)

# 使用自动URL路由连接我们的API。
# 另外，我们还包括支持浏览器浏览API的登录URL。
urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
```

### 添加全局配置

我们也想设置一些全局设置。我们想打开分页，我们希望我们的API只能由管理员使用。设置模块都在 tutorial/settings.py 中。

```python
INSTALLED_APPS = (
    ...
    'rest_framework',
)

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAdminUser',
    ],
    'PAGE_SIZE': 10
}
```

## Serialization

## requests-and-responses

## class-based-views

## authentication-and-permissions

## relationships-and-hyperlinked-apis

## viewsets-and-routers

## schemas-and-client-libraries