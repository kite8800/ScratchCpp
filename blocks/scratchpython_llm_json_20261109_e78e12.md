# LLM 积木说明书（14 个分类）

> 按 LLM 处理顺序编排：分词 → 数据 → 本地模型 → 推理 → 训练 → 对齐 → 提示工程 → 评测 → 框架 → 向量库 → 部署 → 缓存限流 → 安全 → 可观测。
> 每个子分组第一个积木是 import（纯参数组 `param` 除外）；多行结构结尾为 `\n    `；`mode` 只有 `line` 和 `exp`。

---

## 1. `cat-py-llm-tokenizer` — LLM / Tokenizer（LLM / 分词器）
图标 `font`。切 `load` / `encode` / `special`，共 12 个。

**`load`（2）**
- `from transformers import AutoTokenizer` — 导入分词器
- `tokenizer = AutoTokenizer.from_pretrained("gpt2")` — 加载分词器

**`encode`（5）**
- `from transformers import AutoTokenizer` — 导入
- `ids = tokenizer.encode(text)` — 文本转 id
- `text = tokenizer.decode(ids)` — id 转文本
- `ids = tokenizer.encode(text, truncation=True, max_length=512)` — 截断编码
- `batch = tokenizer(texts, padding=True, return_tensors="pt")` — 批量 padding 编码

**`special`（5）**
- `from transformers import AutoTokenizer` — 导入
- `bos = tokenizer.bos_token_id` — 起始 token id
- `eos = tokenizer.eos_token_id` — 结束 token id
- `pad = tokenizer.pad_token_id` — 填充 token id
- `lengths = [len(tokenizer.encode(t)) for t in texts]` — 长度分布统计

---

## 2. `cat-py-llm-data` — LLM / Data（LLM / 数据准备）
图标 `database`。切 `read` / `clean` / `split`，共 16 个。

**`read`（5）**
- `import json` — 导入
- `from datasets import load_dataset` — 导入数据集库
- `rows = [json.loads(l) for l in open("data.jsonl")]` — 读 jsonl
- `ds = load_dataset("json", data_files="data.jsonl")` — 加载 json 数据集
- `ds = load_dataset("csv", data_files="data.csv")` — 加载 csv 数据集

**`clean`（6）**
- `import re` — 导入
- `text = text.strip()` — 去首尾空白
- `text = re.sub(r"\s+", " ", text)` — 正则压空白
- `rows = list({r["text"]: r for r in rows}.values())` — 按文本去重
- `rows = [r for r in rows if len(r["text"]) > 10]` — 过滤短文本
- `row = {"instruction": q, "response": a}` — 构造指令/回复格式

**`split`（5）**
- `from datasets import load_dataset` — 导入
- `ds = ds.train_test_split(test_size=0.1)` — 切分训练/验证
- `train_ds = ds["train"]` — 取训练集
- `val_ds = ds["test"]` — 取验证集
- `ds.save_to_disk("out")` — 保存到磁盘

---

## 3. `cat-py-llm-local` — LLM / Local Model（LLM / 本地模型）
图标 `cubes`。切 `load` / `generate` / `param`，共 16 个。

**`load`（6）**
- `import torch` — 导入
- `from transformers import AutoModelForCausalLM, AutoTokenizer` — 导入模型与分词器
- `tokenizer = AutoTokenizer.from_pretrained("gpt2")` — 加载分词器
- `model = AutoModelForCausalLM.from_pretrained("gpt2")` — 加载模型
- `model.to("cuda")` — 放到 GPU
- `model.eval()` — 切推理模式

**`generate`（4）**
- `from transformers import AutoModelForCausalLM, AutoTokenizer` — 导入
- `inputs = tokenizer(prompt, return_tensors="pt")` — 编码输入
- `out = model.generate(**inputs, max_new_tokens=128)` — 生成
- `text = tokenizer.decode(out[0], skip_special_tokens=True)` — 解码输出

**`param`（6，`exp`，无 import）**
- `max_new_tokens=128`
- `do_sample=True`
- `top_k=50`
- `top_p=0.9`
- `temperature=0.7`
- `repetition_penalty=1.1`

---

## 4. `cat-py-llm-infer` — LLM / Inference（LLM / 推理服务）
图标 `terminal`。切 `server` / `client`，共 8 个。

**`server`（3）**
- `import subprocess` — 导入
- `subprocess.run(["ollama", "serve"])` — 启动 ollama 服务
- `subprocess.run(["ollama", "pull", "llama3"])` — 拉取模型

**`client`（5）**
- `import requests` — 导入
- `resp = requests.post("http://localhost:11434/api/generate", json={"model": "llama3", "prompt": prompt})` — 发请求
- `text = resp.json()["response"]` — 取回复
- `resp = requests.post(..., json={...}, stream=True)` — 流式请求
- `for line in resp.iter_lines():` — 逐行读流式结果（多行）

---

## 5. `cat-py-llm-train` — LLM / Training（LLM / 训练）
图标 `bolt`。切 `data` / `train` / `save`，共 14 个。

**`data`（4）**
- `from datasets import load_dataset` — 导入
- `ds = load_dataset("json", data_files="data.jsonl")` — 加载训练数据
- `def tokenize(ex): return tokenizer(ex["text"])` — 定义 tokenize 函数
- `ds = ds.map(tokenize)` — 批量 tokenize

**`train`（6）**
- `from transformers import TrainingArguments, Trainer` — 导入
- `args = TrainingArguments(output_dir="out", num_train_epochs=1)` — 训练参数
- `trainer = Trainer(model=model, args=args, train_dataset=ds)` — 构造 Trainer
- `trainer.train()` — 开始训练
- `from peft import LoraConfig, get_peft_model` — 导入 PEFT
- `model = get_peft_model(model, LoraConfig(r=8))` — 套 LoRA

**`save`（4）**
- `from transformers import TrainingArguments, Trainer` — 导入
- `trainer.save_model("out")` — 保存模型
- `tokenizer.save_pretrained("out")` — 保存分词器
- `trainer.push_to_hub("repo")` — 推送到 Hub

---

## 6. `cat-py-llm-align` — LLM / Alignment（LLM / 对齐）
图标 `balance-scale`。切 `pref` / `dpo`，共 8 个。

**`pref`（3）**
- `from datasets import load_dataset` — 导入
- `ds = load_dataset("json", data_files="pref.jsonl")` — 加载偏好数据
- `row = {"prompt": p, "chosen": a, "rejected": b}` — 构造偏好样本

**`dpo`（5）**
- `from trl import DPOTrainer` — 导入 DPO
- `trainer = DPOTrainer(model=model, args=args, train_dataset=ds)` — 构造 DPO 训练器
- `trainer.train()` — 开始 DPO 训练
- `from trl import RewardTrainer` — 导入奖励模型训练器
- `samples = [model.generate(...) for _ in range(n)]` — 拒绝采样

---

## 7. `cat-py-llm-prompt` — LLM / Prompt Engineering（LLM / 提示工程）
图标 `magic`。切 `chain` / `react` / `template`，共 9 个。

**`chain`（3）**
- `prompt = "Let's think step by step."` — 思维链
- `prompt = "First analyze the problem, then solve it step by step, finally give the answer."` — 分步提示
- `for _ in range(5):` — Self-Consistency 多次采样（多行）

**`react`（3）**
- `prompt = "Thought: ... Action: ... Observation: ..."` — ReAct 模板
- `for step in range(max_steps):` — ReAct 循环（多行）
- `if "Action:" in text:` — 检测 Action（多行）

**`template`（3）**
- `from jinja2 import Template` — 导入
- `t = Template("Hello {{ name }}")` — 定义模板
- `prompt = t.render(name="Alice")` — 渲染模板

---

## 8. `cat-py-llm-eval` — LLM / Evaluation（LLM / 评测）
图标 `chart-line`。切 `bench` / `judge` / `report`，共 10 个。

**`bench`（4）**
- `import evaluate` — 导入
- `bleu = evaluate.load("bleu")` — 加载 BLEU
- `score = bleu.compute(predictions=preds, references=refs)` — 计算分数
- `acc = sum(scores) / len(scores)` — 准确率汇总

**`judge`（3）**
- `judge_prompt = f"Rate 1-5: {text}"` — LLM-as-judge 提示词
- `score = int(text.strip())` — 解析评分
- `same = text_a.strip() == text_b.strip()` — 两次输出对比

**`report`（3）**
- `import json` — 导入
- `text = json.dumps(results, ensure_ascii=False)` — 序列化结果
- `print(f"acc={acc:.2f}")` — 打印准确率

---

## 9. `cat-py-llm-framework` — LLM / Framework（LLM / 应用框架）
图标 `link`。切 `chain` / `memory` / `retriever`，共 10 个。

**`chain`（4）**
- `from langchain.chains import LLMChain` — 导入链
- `from langchain.prompts import PromptTemplate` — 导入提示模板
- `chain = prompt | llm` — 组装链
- `out = chain.invoke({"topic": "Python"})` — 调用链

**`memory`（3）**
- `from langchain.memory import ConversationBufferMemory` — 导入记忆
- `memory = ConversationBufferMemory()` — 创建记忆
- `memory.save_context({"input": q}, {"output": a})` — 保存对话

**`retriever`（3）**
- `from langchain.vectorstores import Chroma` — 导入向量库
- `retriever = db.as_retriever()` — 转检索器
- `docs = retriever.invoke(query)` — 检索文档

---

## 10. `cat-py-llm-vector` — LLM / Vector Store（LLM / 向量库）
图标 `database`。切 `store` / `search`，共 9 个。

**`store`（4）**
- `import chromadb` — 导入
- `client = chromadb.Client()` — 创建客户端
- `col = client.create_collection("docs")` — 创建集合
- `col.add(documents=docs, ids=ids)` — 写入文档

**`search`（5）**
- `import faiss` — 导入 FAISS
- `index = faiss.IndexFlatL2(dim)` — 建 L2 索引
- `index.add(vectors)` — 写入向量
- `res = col.query(query_texts=[q], n_results=3)` — 查询 top-3
- `docs = res["documents"][0]` — 取文档结果

---

## 11. `cat-py-llm-deploy` — LLM / Deploy（LLM / 部署）
图标 `upload`。切 `api` / `container` / `health`，共 9 个。

**`api`（4）**
- `from fastapi import FastAPI` — 导入 FastAPI
- `app = FastAPI()` — 创建应用
- `@app.post("/generate")` — 定义生成接口（多行）
- `uvicorn.run(app, host="0.0.0.0", port=8000)` — 启动服务

**`container`（3）**
- `import subprocess` — 导入
- `subprocess.run(["vllm", "serve", "model"])` — 启动 vLLM
- `subprocess.run(["docker", "run", "-p", "8000:8000", "img"])` — 启动容器

**`health`（2）**
- `import requests` — 导入
- `ok = requests.get("http://localhost:8000/health").ok` — 健康检查

---

## 12. `cat-py-llm-cache` — LLM / Cache（LLM / 缓存限流）
图标 `database`。切 `memory_cache` / `rate`，共 9 个。

**`memory_cache`（5）**
- `import time` — 导入
- `cache = {}` — 创建缓存字典
- `text = cache.get(prompt)` — 查缓存
- `cache[prompt] = text` — 写缓存
- `expire = time.time() + 3600` — 设置 TTL

**`rate`（4）**
- `import time` — 导入
- `time.sleep(1)` — 限速等待
- `if cost > budget:` — 预算判断（多行）
- `for attempt in range(3):` — 重试循环（多行）

---

## 13. `cat-py-llm-safety` — LLM / Safety（LLM / 安全护栏）
图标 `exclamation-triangle`。切 `input` / `output`，共 6 个。

**`input`（3）**
- `import re` — 导入
- `if "ignore previous" in prompt.lower():` — 注入检测（多行）
- `text = re.sub(r"\d{11}", "***", text)` — PII 打码

**`output`（3）**
- `import re` — 导入
- `if bad_word in text: text = "..."` — 敏感词过滤（多行）
- `if system_prompt in text:` — 系统提示词泄漏检测（多行）

---

## 14. `cat-py-llm-observe` — LLM / Observability（LLM / 可观测）
图标 `monitor`。切 `log` / `trace` / `cost`，共 10 个。

**`log`（3）**
- `import logging` — 导入
- `logging.basicConfig(level=logging.INFO)` — 配置日志
- `logging.info(f"prompt={prompt[:50]}")` — 记录日志

**`trace`（4）**
- `import json` — 导入
- `trace = []` — 创建轨迹列表
- `trace.append({"step": step, "text": text})` — 追加步骤
- `text = json.dumps(trace, ensure_ascii=False)` — 序列化轨迹

**`cost`（3）**
- `import tiktoken` — 导入
- `n = len(tiktoken.get_encoding("cl100k_base").encode(text))` — token 计数
- `cost = n * 0.000002` — 成本估算

---

## 汇总

| # | 分类 | 子分组 | 积木数 |
|---|---|---|---|
| 1 | LLM / Tokenizer | load + encode + special | 12 |
| 2 | LLM / Data | read + clean + split | 16 |
| 3 | LLM / Local Model | load + generate + param | 16 |
| 4 | LLM / Inference | server + client | 8 |
| 5 | LLM / Training | data + train + save | 14 |
| 6 | LLM / Alignment | pref + dpo | 8 |
| 7 | LLM / Prompt Engineering | chain + react + template | 9 |
| 8 | LLM / Evaluation | bench + judge + report | 10 |
| 9 | LLM / Framework | chain + memory + retriever | 10 |
| 10 | LLM / Vector Store | store + search | 9 |
| 11 | LLM / Deploy | api + container + health | 9 |
| 12 | LLM / Cache | memory_cache + rate | 9 |
| 13 | LLM / Safety | input + output | 6 |
| 14 | LLM / Observability | log + trace + cost | 10 |

合计 **14 类、146 个积木**。