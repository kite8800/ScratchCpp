# AI 积木说明书（13 个分类）

> 说明：每个子分组**第一个积木是 import**（`param` 纯参数组除外）；重复 import 用不同 id；`mode` 只有 `line`（完整语句/多行结构）和 `exp`（表达式片段）；多行结构结尾为 `\n    `，光标落在缩进后。依赖 `openai`、`tiktoken`。

---

## 1. `cat-py-ai-client` — AI / Client（AI / 客户端）
图标 `keyboard`，不切子分组，全部在 `none`。共 6 个：
- `from openai import OpenAI` — 导入 SDK
- `import os` — 读环境变量用
- `client = OpenAI(api_key="sk-...")` — 显式传 key 建客户端
- `client = OpenAI()` — 从环境变量读 key
- `client = OpenAI(base_url="...", api_key="...")` — 接自建/第三方兼容接口
- `client = OpenAI(timeout=30)` — 设置超时

---

## 2. `cat-py-ai-prompt` — AI / Prompt（AI / 提示词）
图标 `magic`，切 `prompt` + `none`。

**`prompt` 组（4 个，纯构造，无 import）**
- `system_prompt = "You are a helpful assistant."` — 系统提示词
- `user_prompt = "Explain Python decorators."` — 用户提示词
- `prompt = f"Summarize: {text}"` — f-string 拼提示词
- `prompt = template.format(topic="Python")` — 模板填充

**`none` 组（5 个）**
- `from openai import OpenAI` — 导入（后面常要调用）
- `messages = [{"role": "system", ...}, {"role": "user", ...}]` — 组装消息列表
- `messages.append({"role": "user", "content": user_prompt})` — 追加用户消息
- `messages.append({"role": "assistant", "content": text})` — 追加助手消息（多轮）
- `messages = [few-shot ...]` — 少样本示例消息

---

## 3. `cat-py-ai-chat` — AI / Chat（AI / 对话调用）
图标 `comment`，切 `call` + `param` + `parse`。

**`call` 组（6 个）**
- `from openai import OpenAI` — 导入
- `client = OpenAI()` — 建客户端
- `resp = client.chat.completions.create(model=..., messages=...)` — 基础调用
- `resp = ...(temperature=0.7)` — 带温度调用
- `resp = ...(max_tokens=256)` — 带最大 token 调用
- `resp = ...(stream=True)` — 流式调用

**`param` 组（4 个，纯 `exp`，无 import）**
- `temperature=0.7`
- `max_tokens=256`
- `top_p=0.9`
- `stop=["\n"]`

**`parse` 组（5 个）**
- `import json` — 解析用
- `text = resp.choices[0].message.content` — 取回复文本
- `reason = resp.choices[0].finish_reason` — 取结束原因
- `n = resp.usage.total_tokens` — 取 token 用量
- `data = json.loads(text)` — 把回复当 JSON 解析

---

## 4. `cat-py-ai-tool` — AI / Tools（AI / 工具调用）
图标 `tools`，切 `schema` + `invoke`。

**`schema` 组（4 个）**
- `import json` — 导入
- `tool = {... 单参数 ...}` — 单参数 tool schema（get_weather）
- `tool = {... 多参数 ...}` — 多参数 tool schema（search）
- `tools = [tool]` — 工具列表

**`invoke` 组（7 个）**
- `import json` — 导入
- `from openai import OpenAI` — 导入
- `resp = ...create(..., tools=tools)` — 带工具调用
- `tool_calls = resp.choices[0].message.tool_calls` — 取工具调用列表
- `args = json.loads(tool_call.function.arguments)` — 解析参数
- `result = get_weather(**args)` — 执行本地函数
- `messages.append({"role": "tool", "tool_call_id": ..., "content": ...})` — 回填工具结果

---

## 5. `cat-py-ai-structured` — AI / Structured Output（AI / 结构化输出）
图标 `database`，不切，全部 `none`。共 6 个：
- `import json`
- `data = json.loads(text)` — 字符串转 dict
- `text = json.dumps(data, ensure_ascii=False)` — dict 转字符串
- `prompt = f"Return JSON with keys name and age for: {text}"` — JSON 输出提示词
- `v = data.get("key")` — 安全取字段
- `items = data["items"]` — 取列表字段

---

## 6. `cat-py-ai-embed` — AI / Embedding（AI / 向量嵌入）
图标 `circle`，切 `embed` + `none`。

**`embed` 组（4 个）**
- `from openai import OpenAI`
- `client = OpenAI()`
- `resp = client.embeddings.create(model="text-embedding-3-small", input=text)` — 向量化
- `vec = resp.data[0].embedding` — 取向量

**`none` 组（4 个，无 import，纯计算）**
- `def cosine(a, b): ...` — 余弦相似度函数
- `sim = cosine(vec_a, vec_b)` — 计算相似度
- `index = {"doc1": vec1, "doc2": vec2}` — 简易向量索引
- `best = max(index, key=lambda k: cosine(vec, index[k]))` — 最近邻

---

## 7. `cat-py-ai-rag` — AI / RAG（AI / 检索增强）
图标 `search`，切 `index` + `retrieve`。

**`index` 组（4 个）**
- `from openai import OpenAI`
- `client = OpenAI()`
- `chunks = [text[i:i+500] for i in range(0, len(text), 500)]` — 分块
- `index = {chunk: embed(chunk) for chunk in chunks}` — 建索引

**`retrieve` 组（6 个）**
- `from openai import OpenAI`
- `client = OpenAI()`
- `top = sorted(index, key=lambda c: cosine(query_vec, index[c]), reverse=True)[:3]` — top-k 检索
- `context = "\n".join(top)` — 拼上下文
- `prompt = f"Context:\n{context}\n\nQuestion: {question}"` — 带上下文提示词
- `resp = ...create(messages=[{"role": "user", "content": prompt}])` — 带上下文提问

---

## 8. `cat-py-ai-util` — AI / Utils（AI / 辅助）
图标 `tools`，不切，全部 `none`。共 10 个：
- `import tiktoken`
- `import time`
- `encoding = tiktoken.get_encoding("cl100k_base")` — 取编码器
- `n = len(encoding.encode(text))` — 文本 token 数
- `n = sum(len(encoding.encode(m["content"])) for m in messages)` — 消息 token 总数
- `for attempt in range(3): try: ... except: ... time.sleep(1)` — 重试
- `cache = {}` — 缓存字典
- `text = cache.get(prompt)` — 查缓存
- `print(f"[AI] {prompt[:50]}")` — 日志
- `cost = n * 0.000002` — 成本估算

---

## 9. `cat-py-ai-image` — AI / Image（AI / 图像）
图标 `star`，不切，全部 `none`。共 6 个：
- `from openai import OpenAI`
- `client = OpenAI()`
- `resp = client.images.generate(model="dall-e-3", prompt=prompt, size="1024x1024")` — 图像生成
- `url = resp.data[0].url` — 取图片 URL
- `resp = ...create(messages=[...image_url...])` — 图像理解
- `text = resp.choices[0].message.content` — 取图像描述

---

## 10. `cat-py-ai-speech` — AI / Speech（AI / 语音）
图标 `wave-square`，不切，全部 `none`。共 6 个：
- `from openai import OpenAI`
- `client = OpenAI()`
- `resp = client.audio.speech.create(model="tts-1", voice="alloy", input=text)` — TTS 合成
- `resp.stream_to_file("out.mp3")` — 保存音频
- `audio_file = open("in.mp3", "rb")` — 打开音频
- `text = client.audio.transcriptions.create(model="whisper-1", file=audio_file).text` — STT 转写

---

## 11. `cat-py-ai-multimodal` — AI / Multimodal（AI / 多模态）
图标 `cubes`，不切，全部 `none`。共 6 个：
- `from openai import OpenAI`
- `client = OpenAI()`
- `content = [{"type": "text", ...}, {"type": "image_url", ...}]` — 多模态 content 数组
- `messages = [{"role": "user", "content": content}]` — 多模态消息
- `resp = ...create(messages=messages)` — 调用
- `text = resp.choices[0].message.content` — 取回复

---

## 12. `cat-py-ai-agent` — AI / Agent（AI / 智能体）
图标 `cubes`，切 `agent` + `none`。

**`agent` 组（6 个）**
- `from openai import OpenAI`
- `import json`
- `prompt = "First make a plan, then answer step by step."` — 计划提示词
- `prompt = "Choose the best tool for the task and explain why."` — 工具选择提示词
- `for step in range(max_steps):` — agent 循环
- `if tool_calls:` — 判断是否有工具调用

**`none` 组（6 个）**
- `import json`
- `trace = []` — 轨迹列表
- `trace.append({"step": step, "text": text})` — 记录步骤
- `print(f"step {step}: {text[:50]}")` — 打印步骤
- `max_steps = 5` — 最大轮数
- `text = json.dumps(trace, ensure_ascii=False)` — 序列化轨迹

---

## 13. `cat-py-ai-eval` — AI / Eval（AI / 评估）
图标 `chart-line`，不切，全部 `none`。共 7 个：
- `import json`
- `dataset = [{"input": "2+2?", "expected": "4"}]` — 评估数据集
- `for case in dataset:` — 逐条遍历
- `score = 1 if text.strip() == case["expected"].strip() else 0` — 单条打分
- `acc = sum(scores) / len(scores)` — 准确率汇总
- `same = text_a.strip() == text_b.strip()` — 两次输出对比
- `text = json.dumps(results, ensure_ascii=False)` — 保存结果

---

## 汇总

| 分类 | 子分组 | 积木数 |
|---|---|---|
| AI / Client | none | 6 |
| AI / Prompt | prompt + none | 9 |
| AI / Chat | call + param + parse | 15 |
| AI / Tools | schema + invoke | 11 |
| AI / Structured Output | none | 6 |
| AI / Embedding | embed + none | 8 |
| AI / RAG | index + retrieve | 10 |
| AI / Utils | none | 10 |
| AI / Image | none | 6 |
| AI / Speech | none | 6 |
| AI / Multimodal | none | 6 |
| AI / Agent | agent + none | 12 |
| AI / Eval | none | 7 |

合计 **13 个分类、约 112 个积木**。需要调整某分类的积木数量或增删子分组，告诉我即可。