---
layout:     post
title:      使用Gradio调用通义千问实现一个chatbot机器人
date:       2024-1-25
author:     呆贝斯
header-img: img/post-bg-rwd.jpg
catalog: true
tags:
    - 大模型
---

# 准备

1. 一台云服务器，安装python及dashscope、dotenv和gradio库
2. 开通模型服务灵积，申请API_KEY

# 编码

```python
import os
from http import HTTPStatus
import dashscope
from dotenv import load_dotenv, find_dotenv
import gradio as gr


def get_dashscope_key():
    # 读取本地/项目的环境变量。
    # find_dotenv()寻找并定位.env文件的路径
    # load_dotenv()读取该.env文件，并将其中的环境变量加载到当前的运行环境中
    # 如果你设置的是全局的环境变量，这行代码则没有任何作用。
    _ = load_dotenv(find_dotenv())
    return os.environ['DASHSCOPE_API_KEY']


def call_with_prompt(prompt: str):
    response = dashscope.Generation.call(
        model="qwen-1.8b-chat",
        prompt=prompt,
        api_key=get_dashscope_key()
    )
    # The response status_code is HTTPStatus.OK indicate success,
    # otherwise indicate request is failed, you can get error code
    # and message from code and message.
    if response.status_code == HTTPStatus.OK:
        print(response.output)  # The output text
        print(response.usage)  # The usage information
        return response.output.text
    else:
        print(response.code)  # The error code.
        print(response.message)  # The error message.
        return response.message


if __name__ == '__main__':
    inputs = gr.inputs.Textbox(lines=7, label="Chat with AI")
    outputs = gr.outputs.Textbox(label="Reply")
    gr.Interface(fn=call_with_prompt, inputs=inputs, outputs=outputs, title="AI Chatbot",
                 description="Ask anything you want",
                 theme="compact").launch(server_name='0.0.0.0', server_port=7860, show_error=True)

```

# 部署

可部署到容器或直接运行

![AI ChatBot](/img/ai_chatbot.png)