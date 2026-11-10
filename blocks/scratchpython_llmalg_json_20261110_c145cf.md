# LLM / ALG 积木说明书

> 共 **20 个分类、226 个积木**，按 LLM 算法处理顺序编排：数据 → 分词 → 嵌入 → 初始化 → 注意力 → 长上下文 → 网络层 → 结构 → 前向与损失 → 训练目标 → 池化 → 解码 → 优化 → 调度 → 正则化 → 对齐 → 量化 → 分析 → 实验 → 示例。
> 每个子分组第一个积木是 import（`exp` 纯参数组除外）；多行结构结尾 `\n    `；`mode` 只有 `line` / `exp`；均无 `py` 键。

---

## 一、汇总

| # | 分类 id | 英文名 | 中文名 | 图标 | 子分组 | 积木数 |
|---|---|---|---|---|---|---|
| 1 | `cat-py-llm-alg-data` | LLM / ALG / Data | 数据 | `database` | sample / format / pack / weight | 12 |
| 2 | `cat-py-llm-alg-tokenize` | LLM / ALG / Tokenize | 分词 | `font` | build / special / text | 12 |
| 3 | `cat-py-llm-alg-embed` | LLM / ALG / Embedding | 嵌入 | `database` | token / pos / init | 10 |
| 4 | `cat-py-llm-alg-init` | LLM / ALG / Init | 初始化 | `magic` | weight / special / resume | 10 |
| 5 | `cat-py-llm-alg-attention` | LLM / ALG / Attention | 注意力 | `cubes` | variants / mask / kernel | 12 |
| 6 | `cat-py-llm-alg-context` | LLM / ALG / Context | 长上下文 | `ruler-horizontal` | extend / compress / sparse / recurrence | 11 |
| 7 | `cat-py-llm-alg-layer` | LLM / ALG / Layer | 网络层 | `cubes` | ffn / norm / residual / moe | 12 |
| 8 | `cat-py-llm-alg-arch` | LLM / ALG / Architecture | 结构 | `cubes` | config / build / stack | 10 |
| 9 | `cat-py-llm-alg-forward` | LLM / ALG / Forward | 前向与损失 | `code` | forward / loss / backward | 11 |
| 10 | `cat-py-llm-alg-objective` | LLM / ALG / Objective | 训练目标 | `equals` | lm / contrast / rl / aux | 12 |
| 11 | `cat-py-llm-alg-pool` | LLM / ALG / Pool | 池化 | `compact` | token / weighted / attn / norm | 15 |
| 12 | `cat-py-llm-alg-decode` | LLM / ALG / Decode | 解码 | `location-arrow` | search / sample / custom | 10 |
| 13 | `cat-py-llm-alg-optim` | LLM / ALG / Optim | 优化 | `tools` | optimizer / schedule / amp / distributed | 11 |
| 14 | `cat-py-llm-alg-schedule` | LLM / ALG / Schedule | 调度 | `chart-line` | lr / curriculum / freeze | 10 |
| 15 | `cat-py-llm-alg-reg` | LLM / ALG / Reg | 正则化 | `balance-scale` | dropout / weight_decay / grad / ema | 10 |
| 16 | `cat-py-llm-alg-align` | LLM / ALG / Align | 对齐 | `balance-scale` | sft / lora / pref / rl / distill | 12 |
| 17 | `cat-py-llm-alg-quant` | LLM / ALG / Quant | 量化 | `compact` | bnb / format / prune | 10 |
| 18 | `cat-py-llm-alg-analysis` | LLM / ALG / Analysis | 分析 | `search` | attention / embedding / probe / attribution | 10 |
| 19 | `cat-py-llm-alg-experiment` | LLM / ALG / Experiment | 实验 | `chart-line` | seed / config / grid / track | 13 |
| 20 | `cat-py-llm-alg-example` | LLM / ALG / Example | 示例 | `play` | model/* + train/* + run/* | 13 |

**分组逻辑**：
- **1~2 类**：数据与分词，把文本变成 id。
- **3~4 类**：嵌入与初始化，把 id 变成向量、把权重初始化好。
- **5~8 类**：模型内部（注意力、长上下文、网络层、结构）。
- **9~10 类**：前向与训练目标，定义「算什么、优化什么」。
- **11 类**：池化，把 hidden 压成句向量。
- **12 类**：解码，把 logits 变 token。
- **13~15 类**：训练过程（优化、调度、正则化）。
- **16~17 类**：后训练与压缩（对齐、量化）。
- **18~19 类**：研究与实验（分析、实验）。
- **20 类**：整段可运行模板。

---

## 二、逐类逐子分组详细解释

### 1. `cat-py-llm-alg-data` — LLM / ALG / Data（数据）
**定位**：算法实验的数据管线——训练样本怎么造、格式怎么定、怎么打包、怎么配比。数据决定算法上限，是研究第一步。
**图标** `database`。子分组 `sample` / `format` / `pack` / `weight`，共 12 个。

**`sample`（3）— 训练样本构造**
- `import torch`：导入 PyTorch。
- `input_ids = ids[:-1]`：输入序列去掉最后一个 token（`exp`）。自回归训练里，模型看前 n-1 个预测第 n 个。
- `labels = ids[1:]`：标签序列去掉第一个 token（`exp`）。与 `input_ids` 错位一位，形成「输入 → 下一 token」监督对。

**`format`（3）— 数据格式**
- `import json`：导入 json。
- `row = {"instruction": q, "response": a}`：指令微调格式，`q` 是问题、`a` 是回答。
- `row = {"prompt": p, "chosen": a, "rejected": b}`：偏好对齐格式，`chosen` 是偏好回答、`rejected` 是拒绝回答，DPO/ORPO 用。

**`pack`（3）— 打包与 padding**
- `import torch`：导入。
- `batch = [x + [pad] * (max_len - len(x)) for x in xs]`：动态 padding，把变长序列补到 `max_len`，同 batch 内对齐。
- `packed = torch.cat(seqs, dim=0)`：packing 拼接（`exp`），把多条短序列拼成一条定长，减少 padding 浪费。

**`weight`（3）— 数据配比与采样**
- `import numpy as np`：导入 numpy。
- `w = np.array([0.7, 0.3])`：数据源配比权重，如 70% 通用 + 30% 领域。
- `idx = np.random.choice(n, size=bs, p=w)`：按权重采样一个 batch，控制训练数据分布。

---

### 2. `cat-py-llm-alg-tokenize` — LLM / ALG / Tokenize（分词）
**定位**：文本与 token id 互转、词表构建与扩展。决定模型「看到」什么粒度。
**图标** `font`。子分组 `build` / `special` / `text`，共 12 个。

**`build`（6）— 从零构建分词器**
- `from tokenizers import Tokenizer`：导入底层分词器类。
- `from tokenizers import trainers`：导入训练器模块（Bpe/WordPiece/Unigram）。
- `tokenizer = Tokenizer.from_file("tokenizer.json")`：加载已保存分词器，复现实验常用。
- `tokenizer = Tokenizer(models.BPE())`：新建空 BPE 分词器，GPT 系列用。
- `trainer = trainers.BpeTrainer(vocab_size=32000)`：BPE 训练器，目标词表 32k，中文常 32k~64k。
- `tokenizer.train_from_iterator(texts, trainer)`：从语料训练词表，训练后应 `tokenizer.save(...)`。

**`special`（3）— 特殊 token 与扩词表**
- `from tokenizers import Tokenizer`：导入。
- `tokenizer.add_special_tokens(["<pad>", "<eos>"])`：加填充/结束 token，加完必须扩模型 embedding。
- `model.resize_token_embeddings(len(tokenizer))`：把 embedding 矩阵扩到新词表大小，否则新 id 越界。

**`text`（4）— 文本与 id 互转**
- `from transformers import AutoTokenizer`：导入高层分词器。
- `ids = tokenizer.encode(text)`：文本转 id，可加 `add_special_tokens=False`。
- `text = tokenizer.decode(ids)`：id 转文本，可加 `skip_special_tokens=True`。
- `ids = tokenizer.encode(text, truncation=True, max_length=512)`：截断编码，防超长爆显存。

---

### 3. `cat-py-llm-alg-embed` — LLM / ALG / Embedding（嵌入）
**定位**：token id 变向量，并注入位置信息。模型「理解」序列的起点。
**图标** `database`。子分组 `token` / `pos` / `init`，共 10 个。

**`token`（4）— token 嵌入**
- `import torch`：导入。
- `import torch.nn as nn`：导入网络模块。
- `emb = nn.Embedding(vocab_size, d_model)`：嵌入层，内部是 `vocab_size × d_model` 可学习矩阵。
- `x = emb(tokens) + pos(positions)`：token 嵌入 + 位置嵌入（`exp`）。

**`pos`（4）— 位置编码**
- `import torch.nn as nn`：导入。
- `pos = nn.Embedding(max_len, d_model)`：绝对位置编码（可学习）。
- `class RoPE(nn.Module):`：RoPE（旋转位置编码）骨架，LLaMA 系列用。
- `class ALiBi(nn.Module):`：ALiBi（线性偏置）骨架，BLOOM 用。

**`init`（3）— 嵌入初始化与缩放**
- `import torch.nn as nn`：导入。
- `nn.init.normal_(emb.weight, std=0.02)`：正态初始化，GPT 系列常用。
- `x = x * (d_model ** 0.5)`：嵌入缩放，平衡嵌入与位置编码量级（`exp`）。

---

### 4. `cat-py-llm-alg-init` — LLM / ALG / Init（初始化）
**定位**：权重初始化策略，决定训练能否稳定起步。是算法研究的常见变量。
**图标** `magic`。子分组 `weight` / `special` / `resume`，共 10 个。

**`weight`（4）— 通用初始化**
- `import torch.nn as nn`：导入。
- `nn.init.xavier_uniform_(layer.weight)`：Xavier，适合 tanh/sigmoid。
- `nn.init.kaiming_normal_(layer.weight)`：Kaiming，适合 ReLU。
- `nn.init.orthogonal_(layer.weight)`：正交初始化，适合 RNN/稳定训练。

**`special`（3）— 特殊初始化**
- `import torch`：导入。
- `x = x * 0.1`：残差缩放（`exp`），GPT2 用 `1/sqrt(2N)` 缩放残差。
- `scale = nn.Parameter(torch.ones(d_model))`：LayerScale，每层一个可学习缩放。

**`resume`（3）— 续训加载**
- `from transformers import AutoModelForCausalLM`：导入。
- `model = AutoModelForCausalLM.from_pretrained("ckpt")`：从 checkpoint 加载，续训常用。
- `model.load_state_dict(torch.load("ckpt.pt"))`：加载自定义权重。

---

### 5. `cat-py-llm-alg-attention` — LLM / ALG / Attention（注意力）
**定位**：token 之间怎么「互相看」。Transformer 核心，研究最活跃。
**图标** `cubes`。子分组 `variants` / `mask` / `kernel`，共 12 个。

**`variants`（5）— 注意力变体**
- `import torch`：导入。
- `import torch.nn as nn`：导入。
- `class MHA(nn.Module):`：多头注意力骨架，每头独立 q/k/v。
- `class MQA(nn.Module):`：多查询注意力骨架，所有头共享 k/v，省 KV cache，PaLM 用。
- `class GQA(nn.Module):`：分组查询注意力骨架，q 多组、k/v 少组，LLaMA2/3 用。

**`mask`（3）— 掩码**
- `import torch`：导入。
- `mask = torch.triu(torch.ones(L, L), diagonal=1).bool()`：因果掩码，位置 i 只能看 ≤ i。
- `sliding_window = 4096`：滑动窗口，Mistral 用（`exp`）。

**`kernel`（4）— 高效核**
- `import torch`：导入。
- `attn = torch.softmax(scores / scale, dim=-1)`：标准 softmax 注意力。
- `from flash_attn import flash_attn_func`：FlashAttention，融合 CUDA kernel。
- `out = flash_attn_func(q, k, v, causal=True)`：调用 FlashAttention，`causal=True` 表示因果掩码。

---

### 6. `cat-py-llm-alg-context` — LLM / ALG / Context（长上下文）
**定位**：长序列算法——位置外推、KV 压缩、稀疏注意力、循环记忆。当前研究热点。
**图标** `ruler-horizontal`。子分组 `extend` / `compress` / `sparse` / `recurrence`，共 11 个。

**`extend`（3）— 位置外推**
- `import torch`：导入。
- `scale = base_len / cur_len`：位置插值（PI）（`exp`），把超出训练长度的位置压回。
- `theta = 10000 * scale ** (dim / (dim - 2))`：NTK-aware 缩放（`exp`），调 RoPE 基底，长上下文更稳。

**`compress`（3）— KV 压缩**
- `import torch`：导入。
- `k = k.repeat_interleave(n_head // n_kv_head, dim=1)`：GQA KV 复制，少 KV 头复制成多头。
- `cache = cache[:, -window:]`：KV cache 截断（`exp`），只保留最近 window 个。

**`sparse`（3）— 稀疏注意力**
- `import torch`：导入。
- `mask = torch.ones(L, L).triu(diagonal=-window)`：滑动窗口掩码，每 token 只看前 window 个。
- `indices = topk(scores, k=64)`：稀疏 top-k 注意力（`exp`），只算最相关 64 个。

**`recurrence`（2）— 循环记忆**
- `import torch`：导入。
- `state = state * decay + x`：循环状态更新（`exp`），RNN/SSM 式记忆，Mamba 思想。

---

### 7. `cat-py-llm-alg-layer` — LLM / ALG / Layer（网络层）
**定位**：Transformer block 内部组件——FFN、归一化、残差、MoE。决定表达能力。
**图标** `cubes`。子分组 `ffn` / `norm` / `residual` / `moe`，共 12 个。

**`ffn`（4）— 前馈网络**
- `import torch.nn as nn`：导入。
- `class MLP(nn.Module):`：标准 FFN 骨架。
- `class SwiGLU(nn.Module):`：SwiGLU 骨架，LLaMA 系列用，效果优于 GELU。
- `from torch.nn import GELU, SiLU`：激活函数，GELU 是 BERT/GPT 常用，SiLU 是 SwiGLU 组件。

**`norm`（3）— 归一化**
- `import torch.nn as nn`：导入。
- `class RMSNorm(nn.Module):`：RMSNorm 骨架，LLaMA 用，比 LayerNorm 少算均值、更快。
- `norm = nn.LayerNorm(d_model)`：标准 LayerNorm，BERT/GPT2 用。

**`residual`（3）— 残差**
- `import torch`：导入。
- `x = x + attn(norm(x))`：注意力残差（Pre-Norm）（`exp`）。
- `x = x + mlp(norm(x))`：FFN 残差（`exp`）。

**`moe`（3）— 混合专家**
- `import torch.nn as nn`：导入。
- `class MoE(nn.Module):`：MoE 骨架，含 gate 与多 expert。
- `top_k = 2`：每 token 激活 top-2 专家，Mixtral 用（`exp`）。

---

### 8. `cat-py-llm-alg-arch` — LLM / ALG / Architecture（结构）
**定位**：把层堆成模型——改配置、建模型、遍历层。模型级操作。
**图标** `cubes`。子分组 `config` / `build` / `stack`，共 10 个。

**`config`（5）— 模型配置**
- `from transformers import AutoConfig`：导入配置类。
- `config = AutoConfig.from_pretrained("gpt2")`：读预训练配置，也可 `AutoConfig()` 从零建。
- `config.n_layer = 12`：改层数（`exp`）。
- `config.n_head = 8`：改头数（`exp`）。
- `config.hidden_size = 768`：改隐藏维（`exp`），注意 `hidden_size % n_head == 0`。

**`build`（3）— 建模型**
- `from transformers import AutoModelForCausalLM`：导入因果语言模型类。
- `model = AutoModelForCausalLM.from_config(config)`：按配置随机初始化，适合从头训练。
- `model.lm_head.weight = model.transformer.wte.weight`：权重共享，GPT2 用，省参数。

**`stack`（2）— 层堆叠**
- `import torch.nn as nn`：导入。
- `for layer in model.transformer.h:`：遍历所有层，可逐层改结构或加 hook。

---

### 9. `cat-py-llm-alg-forward` — LLM / ALG / Forward（前向与损失）
**定位**：一次前向怎么算、损失怎么定义、梯度怎么回传。训练信号的来源。
**图标** `code`。子分组 `forward` / `loss` / `backward`，共 11 个。

**`forward`（3）— 前向**
- `import torch`：导入。
- `def forward(self, x):`：forward 骨架（多行）。
- `logits = self.lm_head(hidden)`：出 logits（`exp`）。

**`loss`（5）— 损失函数**
- `import torch.nn.functional as F`：导入函数式接口。
- `loss = F.cross_entropy(logits.view(-1, V), labels.view(-1))`：交叉熵，`V` 是词表大小。
- `loss = F.cross_entropy(logits, labels, label_smoothing=0.1)`：label smoothing，防过拟合。
- `loss = F.kl_div(log_probs, target_probs)`：KL 散度，蒸馏/RLHF 用。
- `loss = contrastive_loss(z1, z2)`：对比损失（`exp`）。

**`backward`（3）— 反向**
- `import torch`：导入。
- `loss.backward()`：反向传播。
- `grad = torch.autograd.grad(loss, emb)[0]`：取指定张量梯度，归因分析用。

---

### 10. `cat-py-llm-alg-objective` — LLM / ALG / Objective（训练目标）
**定位**：除了 CE/KL，还有哪些训练目标——CLM/MLM/span、对比、RL、辅助损失。算法研究常改目标。
**图标** `equals`。子分组 `lm` / `contrast` / `rl` / `aux`，共 12 个。

**`lm`（4）— 语言建模目标**
- `import torch.nn.functional as F`：导入。
- `loss = F.cross_entropy(logits, labels)`：CLM，因果语言建模，GPT 用。
- `loss = F.cross_entropy(logits[mask], labels[mask])`：MLM，只算 mask 位，BERT 用。
- `loss = F.cross_entropy(logits, labels, reduction="mean")`：span corruption 示意，T5 用。

**`contrast`（3）— 对比目标**
- `import torch.nn.functional as F`：导入。
- `loss = F.cross_entropy(sim / T, targets)`：InfoNCE，对比学习常用。
- `loss = (1 - F.cosine_similarity(z1, z2)).mean()`：SimCSE，句向量对比。

**`rl`（3）— 强化学习目标**
- `import torch`：导入。
- `ratio = torch.exp(logp - logp_old)`：PPO ratio（`exp`）。
- `loss = -torch.min(ratio * adv, torch.clamp(ratio, 0.8, 1.2) * adv).mean()`：PPO clipped loss，RLHF 用。

**`aux`（2）— 辅助目标**
- `import torch`：导入。
- `loss = loss + 0.1 * aux_loss`：辅助损失加权（`exp`），如 MoE 负载均衡、MTP 多 token 预测。

---

### 11. `cat-py-llm-alg-pool` — LLM / ALG / Pool（池化）
**定位**：把 `[batch, seq, hidden]` 压成 `[batch, hidden]`，得到句向量。embedding 模型、RAG、句相似度的关键一步。
**图标** `compact`。子分组 `token` / `weighted` / `attn` / `norm`，共 15 个。

**`token`（5）— token 维池化**
- `import torch`：导入。
- `vec = hidden.mean(dim=1)`：mean pooling，最常用的句向量池化。
- `vec = hidden[:, 0]`：CLS pooling，取 `[CLS]` 位置，BERT 分类常用。
- `vec = hidden[:, -1]`：last-token pooling，E5/GTE 等 decoder 句向量常用。
- `vec = hidden.max(dim=1).values`：max pooling，文本分类常用。

**`weighted`（3）— 加权池化**
- `import torch`：导入。
- `mask = attention_mask.unsqueeze(-1)`：mask 扩成 3D，与 hidden 对齐（`exp`）。
- `vec = (hidden * mask).sum(1) / mask.sum(1)`：mask 加权 mean pooling，变长 batch 的正确写法，避免 padding 污染。

**`attn`（3）— 注意力池化**
- `import torch.nn as nn`：导入。
- `class AttentionPooling(nn.Module):`：注意力池化骨架（多行），学习每 token 权重。
- `w = torch.softmax(scores, dim=1)`：池化权重归一化（`exp`）。

**`norm`（4）— 归一化与相似度**
- `import torch.nn.functional as F`：导入。
- `vec = F.normalize(vec, dim=-1)`：L2 归一化，向量检索前必做。
- `sim = torch.matmul(a, b.T)`：余弦相似度矩阵，批量两两相似度。
- `sim = F.cosine_similarity(a, b, dim=-1)`：逐对余弦相似度。

---

### 12. `cat-py-llm-alg-decode` — LLM / ALG / Decode（解码）
**定位**：模型怎么「生成」下一个 token。搜索、采样、约束解码，决定输出质量与多样性。
**图标** `location-arrow`。子分组 `search` / `sample` / `custom`，共 10 个。

**`search`（3）— 搜索**
- `import torch`：导入。
- `out = model.generate(**inputs, do_sample=False)`：greedy，每步取最大概率，确定但可能重复。
- `out = model.generate(**inputs, num_beams=4)`：beam search，保留 4 条候选，质量更高但更慢。

**`sample`（5）— 采样**
- `import torch`：导入。
- `out = model.generate(**inputs, top_k=50)`：top-k，只从概率前 50 采。
- `out = model.generate(**inputs, top_p=0.9)`：top-p（核）采样，从累积概率 0.9 采，更动态。
- `out = model.generate(**inputs, temperature=0.7)`：温度采样，`<1` 更确定，`>1` 更随机。
- `temperature=0.7`：参数片段（`exp`）。

**`custom`（3）— 自定义**
- `from transformers import LogitsProcessor`：导入 logits 处理器基类。
- `class MyLogitsProcessor(LogitsProcessor):`：自定义约束解码骨架（多行），如强制 JSON 格式。
- `from transformers import AssistedGenerationCandidateGenerator`：投机解码，小模型草稿、大模型验证，提速。

---

### 13. `cat-py-llm-alg-optim` — LLM / ALG / Optim（优化）
**定位**：参数怎么更新。优化器、混合精度、分布式，决定训练效率与稳定性。
**图标** `tools`。子分组 `optimizer` / `schedule` / `amp` / `distributed`，共 11 个。

**`optimizer`（3）— 优化器**
- `import torch`：导入。
- `from torch.optim import AdamW`：AdamW，Transformer 标配。
- `optimizer = AdamW(model.parameters(), lr=1e-4)`：构造优化器，`lr=1e-4` 常见起点。

**`schedule`（3）— 调度与裁剪**
- `from transformers import get_linear_schedule_with_warmup`：线性 warmup 调度器。
- `scheduler = get_linear_schedule_with_warmup(optimizer, 100, 1000)`：前 100 步 warmup，总 1000 步线性衰减。
- `torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)`：梯度裁剪，防爆炸。

**`amp`（3）— 混合精度**
- `from torch.cuda.amp import autocast, GradScaler`：AMP 工具。
- `with autocast():`：自动混合精度上下文（多行），内部用 fp16/bf16，省显存提速。
- `scaler.scale(loss).backward()`：缩放反传，防下溢。

**`distributed`（2）— 分布式**
- `from torch.nn.parallel import DistributedDataParallel`：DDP，多卡数据并行。
- `loss = loss / accum_steps`：梯度累积，小显存模拟大 batch（`exp`）。

---

### 14. `cat-py-llm-alg-schedule` — LLM / ALG / Schedule（调度）
**定位**：训练过程调度——学习率曲线、课程学习、冻结策略。研究常用变量。
**图标** `chart-line`。子分组 `lr` / `curriculum` / `freeze`，共 10 个。

**`lr`（4）— 学习率曲线**
- `import math`：导入。
- `lr = base_lr * 0.5 * (1 + math.cos(math.pi * step / total))`：cosine 衰减（`exp`），最常用。
- `lr = base_lr * min(step / warmup, 1.0)`：linear warmup（`exp`）。
- `lr = base_lr`：constant（`exp`），小模型/微调常用。

**`curriculum`（3）— 课程学习**
- `import torch`：导入。
- `max_len = min(base_len + step * 128, max_len)`：长度递增（`exp`），从短序列训到长序列。
- `if step > warmup: unfreeze(layer)`：逐步解冻（多行），先冻结底层再逐层解冻。

**`freeze`（3）— 冻结策略**
- `import torch`：导入。
- `for p in model.parameters(): p.requires_grad = False`：全冻结（多行），只做推理或只训头部。
- `for p in model.lm_head.parameters(): p.requires_grad = True`：只训 lm_head（多行），线性探针/适配常用。

---

### 15. `cat-py-llm-alg-reg` — LLM / ALG / Reg（正则化）
**定位**：防过拟合与稳定训练——dropout、权重衰减、梯度处理、EMA。现在 Optim 只有梯度裁剪一条，不够。
**图标** `balance-scale`。子分组 `dropout` / `weight_decay` / `grad` / `ema`，共 10 个。

**`dropout`（4）— dropout**
- `import torch.nn as nn`：导入。
- `drop = nn.Dropout(0.1)`：标准 dropout，随机置零。
- `drop = nn.Dropout2d(0.1)`：attention dropout 示意。
- `p = 0.1`：drop path 概率（`exp`），随机跳过整个残差分支。

**`weight_decay`（2）— 权重衰减**
- `import torch`：导入。
- `optimizer = torch.optim.AdamW(model.parameters(), weight_decay=0.01)`：L2 正则，AdamW 解耦实现。

**`grad`（3）— 梯度处理**
- `import torch`：导入。
- `torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)`：梯度裁剪，防爆炸。
- `p.grad += torch.randn_like(p.grad) * 0.01`：梯度噪声，差分隐私/稳定训练。

**`ema`（2）— 指数移动平均**
- `import torch`：导入。
- `ema = 0.999 * ema + 0.001 * model.state_dict()`：EMA 更新（`exp`），评估/推理用平滑权重。

---

### 16. `cat-py-llm-alg-align` — LLM / ALG / Align（对齐）
**定位**：让模型「听话」——SFT、LoRA、偏好对齐、RLHF、蒸馏。后训练核心。
**图标** `balance-scale`。子分组 `sft` / `lora` / `pref` / `rl` / `distill`，共 12 个。

**`sft`（3）— 监督微调**
- `from transformers import Trainer`：导入 Trainer。
- `trainer = Trainer(model=model, args=args, train_dataset=ds)`：构造 SFT 训练器。
- `from trl import SFTTrainer`：TRL 的 SFTTrainer，专为指令微调优化。

**`lora`（3）— 参数高效微调**
- `from peft import LoraConfig, get_peft_model`：导入 LoRA。
- `model = get_peft_model(model, LoraConfig(r=8))`：套 LoRA，`r=8` 是秩。
- `from peft import prepare_model_for_kbit_training`：QLoRA 准备，量化模型训练前要调。

**`pref`（3）— 偏好对齐**
- `from trl import DPOTrainer`：DPO，直接用偏好数据优化，无需 reward model。
- `from trl import ORPOTrainer`：ORPO，把 SFT 和偏好对齐合并成一步。
- `from trl import KTOTrainer`：KTO，只需「好/坏」标签，不需成对偏好。

**`rl`（2）— 强化学习**
- `from trl import PPOTrainer`：PPO/RLHF，经典算法，需 reward model。
- `from trl import RewardTrainer`：训练 reward model。

**`distill`（2）— 蒸馏**
- `import torch.nn.functional as F`：导入。
- `kd_loss = alpha * ce_loss + (1 - alpha) * kl_loss`：蒸馏损失（`exp`），`alpha` 平衡硬/软标签。

---

### 17. `cat-py-llm-alg-quant` — LLM / ALG / Quant（量化）
**定位**：把模型压小——低比特、量化格式、剪枝。决定能否在有限显存/边缘设备跑。
**图标** `compact`。子分组 `bnb` / `format` / `prune`，共 10 个。

**`bnb`（3）— BitsAndBytes**
- `from transformers import BitsAndBytesConfig`：导入量化配置。
- `bnb = BitsAndBytesConfig(load_in_4bit=True)`：4bit，显存省 4 倍，质量略降。
- `bnb = BitsAndBytesConfig(load_in_8bit=True)`：8bit，显存省 2 倍，质量基本无损。

**`format`（4）— 量化格式**
- `from auto_gptq import AutoGPTQForCausalLM`：GPTQ，训练后量化，4bit 常用。
- `from awq import AutoAWQForCausalLM`：AWQ，激活感知量化，比 GPTQ 更稳。
- `from llama_cpp import Llama`：GGUF（llama.cpp），CPU/边缘设备常用。
- `llm = Llama(model_path="model.gguf")`：加载 GGUF 模型。

**`prune`（3）— 剪枝**
- `import torch`：导入。
- `pruned = torch.nn.utils.prune.l1_unstructured(...)`：L1 非结构化剪枝，按权重绝对值剪小的。
- `torch.save(model.state_dict(), "out.pt")`：保存剪枝后模型。

---

### 18. `cat-py-llm-alg-analysis` — LLM / ALG / Analysis（分析）
**定位**：模型「为什么这样输出」——注意力可视化、嵌入降维、探针、归因。研究者的显微镜。
**图标** `search`。子分组 `attention` / `embedding` / `probe` / `attribution`，共 10 个。

**`attention`（4）— 注意力分析**
- `import matplotlib.pyplot as plt`：导入绘图。
- `attn = outputs.attentions[0]`：取第一层注意力（`exp`），需 `output_attentions=True`。
- `plt.imshow(attn[0, 0].cpu())`：画热力图，`[0, 0]` 是第 0 样本第 0 头。
- `plt.savefig("attn.png")`：保存图。

**`embedding`（4）— 嵌入分析**
- `from sklearn.decomposition import PCA`：导入 PCA。
- `X = PCA(n_components=2).fit_transform(hidden)`：降到 2 维，也可换 t-SNE/UMAP。
- `plt.scatter(X[:, 0], X[:, 1])`：散点图。
- `vec = hidden.mean(dim=1)`：先取句向量再做降维，嵌入可视化的常见前置。

**`probe`（2）— 线性探针**
- `import torch.nn as nn`：导入。
- `probe = nn.Linear(hidden_size, n_classes)`：线性探针，在冻结表示上训分类器，测表示质量。

**`attribution`（3）— 归因**
- `import torch`：导入。
- `grad = torch.autograd.grad(loss, emb)[0]`：取嵌入梯度。
- `importance = (grad * emb).sum(-1)`：梯度×输入归因（`exp`），衡量每 token 重要性。

---

### 19. `cat-py-llm-alg-experiment` — LLM / ALG / Experiment（实验）
**定位**：让实验可复现、可对比——种子、配置、网格、记录。算法研究的「实验台」。
**图标** `chart-line`。子分组 `seed` / `config` / `grid` / `track`，共 13 个。

**`seed`（4）— 固定种子**
- `import random`：导入。
- `import numpy as np`：导入。
- `import torch`：导入。
- `random.seed(42); np.random.seed(42); torch.manual_seed(42)`：三行固定种子（多行），GPU 还要 `torch.cuda.manual_seed_all(42)`。

**`config`（3）— 实验配置**
- `import json`：导入。
- `config = {"lr": 1e-4, "bs": 8}`：实验配置字典。
- `text = json.dumps(config, ensure_ascii=False)`：序列化配置，便于保存/复现。

**`grid`（3）— 超参网格**
- `import itertools`：导入。
- `for lr in [1e-5, 2e-5, 1e-4]:`：学习率网格（多行）。
- `for bs in [8, 16]:`：batch size 网格（多行），可嵌套或 `itertools.product`。

**`track`（4）— 结果记录**
- `import json`：导入。
- `results.append({"lr": lr, "bs": bs, "acc": acc})`：记录一组结果。
- `text = json.dumps(results, ensure_ascii=False)`：序列化全部结果。
- `same = abs(acc_a - acc_b) < 0.01`：A/B 对比（`exp`），判断差异是否显著（简易版）。

---

### 20. `cat-py-llm-alg-example` — LLM / ALG / Example（示例）
**定位**：整段可运行模板，拖进去改默认值即可。从片段到可跑的桥。
**图标** `play`。子分组键用 `组名 / 项名` 形式，共 13 个。

**`model / min-gpt`（1）**
- `class MiniGPT(nn.Module):`：最小 GPT 类，含 embedding、N 层 `TransformerEncoderLayer`、lm_head、因果掩码、cross-entropy loss。改 `vocab_size=1000` / `d_model=256` / `n_head=4` / `n_layer=4`。适合理解 GPT 骨架。

**`model / gqa`（1）**
- `class GQA(nn.Module):`：完整 GQA，q 有 `n_head` 份、k/v 有 `n_kv_head` 份，`repeat_interleave` 复制 KV，softmax 注意力，输出投影。改 `d_model=256` / `n_head=8` / `n_kv_head=2`。适合研究 LLaMA 注意力。

**`model / rope`（1）**
- `class RoPE(nn.Module):`：完整 RoPE，`inv_freq = 1/(10000^(2i/d))`，`outer` 算 freqs，cos/sin，奇偶维旋转。改 `dim`。适合研究位置编码。

**`model / moe`（1）**
- `class MoE(nn.Module):`：完整 MoE，gate 算路由分数，`topk` 选专家，逐专家加权求和。改 `d_model=256` / `n_expert=4` / `top_k=2`。适合研究 Mixtral 式结构。

**`model / sentence-encoder`（1）**
- `sentence encoder: pool + normalize`：完整句向量编码器，加载 BERT → 前向 → mask 加权 mean pooling → L2 归一化 → 余弦相似度矩阵。改 `bert-base-uncased` 为你的模型。适合做 embedding/RAG。

**`train / loop`（1）**
- `for epoch in range(epochs):`：最小训练循环，AdamW、分批、forward、backward、step、打印 loss。改 `epochs=10` / `lr=1e-4` / 数据。适合验证模型能跑。

**`train / sft`（1）**
- `SFT: Trainer(...).train()`：最小 SFT 脚本，`load_dataset("json")`、tokenize、`TrainingArguments`、`Trainer`、`train`、`save_model`。改 `model_name="gpt2"` / `data.jsonl` / `out`。适合指令微调入门。

**`train / lora`（1）**
- `LoRA: get_peft_model(...)`：最小 LoRA 脚本，`LoraConfig(r=8, lora_alpha=16, target_modules=["c_attn"])`、`get_peft_model`、`Trainer`、`save_pretrained`。改 `r` / `target_modules`（不同模型层名不同）。适合低显存微调。

**`train / dpo`（1）**
- `DPO: DPOTrainer(...).train()`：最小 DPO 脚本，偏好数据 `pref.jsonl`（含 prompt/chosen/rejected）、`DPOConfig(beta=0.1)`、`DPOTrainer`、`train`。改 `beta` / 数据路径。适合偏好对齐入门。

**`train / distill`（1）**
- `KD: alpha*CE + (1-alpha)*KL`：最小蒸馏脚本，教师/学生模型、教师前向取 logits、学生前向、CE+KL 加权、反传。改 `alpha=0.5` / `T=2.0` / 模型名。适合模型压缩。

**`train / ppo`（1）**
- `PPO: PPOTrainer(...).step(...)`：最小 PPO/RLHF 骨架，`PPOConfig`、`PPOTrainer`、`generate`、`score` 打分、`step`。需补 `queries` 和 `score` 函数。适合 RLHF 入门。

**`run / generate`（1）**
- `generate: model.generate(...)`：最小推理脚本，加载模型、tokenizer、`generate(max_new_tokens=64, do_sample=True, top_p=0.9)`、decode、print。改 `prompt` / 参数。适合快速试模型。

**`run / eval`（1）**
- `eval: for case in dataset ...`：最小评测脚本，读 `eval.jsonl`、逐条生成、比对 expected、汇总 acc、打印。改 `model_name` / `eval.jsonl`。适合跑基准。

---

## 三、依赖总览

`torch`、`transformers`、`tokenizers`、`peft`、`trl`、`datasets`、`numpy`、`bitsandbytes`、`auto-gptq`、`awq`、`llama-cpp-python`、`flash-attn`、`matplotlib`、`scikit-learn`。

## 四、使用建议

- **1~8 类**：模型内部，适合改结构、做研究。
- **9~12 类**：训练信号与生成，调目标/解码。
- **13~15 类**：训练过程，工程性强。
- **16~17 类**：后训练与压缩。
- **18~19 类**：研究工具，配合使用。
- **20 类**：整段模板，入门与验证首选。

