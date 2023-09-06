---
layout:     post
title:      Django 10行代码自动注册所有Model到管理后台
subtitle:   ......
date:       2022-5-23
author:     呆贝斯
header-img: img/post-bg-desk.jpg
catalog: true
tags:
    - Django
---
# 场景
* 实际的业务场景中，往往Model多达几十个
* 一个个写Admin，再Register，效率低

# 思考
能自动注册Model到管理后台

# 方案
1. 在项目配置目录下新建一个文件夹apps，再在文件夹下穿件项目同名APP
2. 重写APP下apps.py文件中AppConfig类的ready方法
    ```
    from django.apps import apps
    
    
    class ListAdminMixin:
        def __init__(self, model, admin_site):
            self.list_display = (field.name for field in model._meta.fields)
            super(ListAdminMixin, self).__init__(model, admin_site)
   
    class UnionAdminApp(AppConfig):
        name = 'project_name'
        
        def ready(self):
            models = apps.get_models()
            for model in models:
                admin_class = type("AdminClass", (ListAdminMixin, admin.ModelAdmin))
                try
                    admin.site.register(model)
                except admin.sites.AlreadyRegistered:
                    pass
    ```
3. 将APP注册到Django最后。