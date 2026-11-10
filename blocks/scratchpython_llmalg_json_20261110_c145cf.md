# LLM / ALG 积木说明书

> 共 **14 个独立分类、161 个积木**，按 LLM 算法处理顺序编排：分词 → 嵌入 → 注意力 → 网络层 → 结构 → 前向与损失 → 池化 → 解码 → 优化 → 对齐 → 量化 → 分析 → 实验 → 示例。
> 每个子分组第一个积木是 import（`exp` 纯参数组除外）；多行结构结尾 `\n    `；`mode` 只有 `line` / `exp`；均无 `py` 键。

---

## 一、汇总

| # | 分类 id | 英文名 | 中文名 | 图标 | 子分组 | 积木数 |
|---|---|---|---|---|---|---|
| 1 | `cat-py-llm-alg-tokenize` | LLM / ALG / Tokenize | LLM / 算法 / 分词 | `font` | build / special / text | 12 |
| 2 | `cat-py-llm-alg-embed` | LLM / ALG / Embedding | LLM / 算法 / 嵌入 | `database` | token / pos / init | 10 |
| 3 | `cat-py-llm-alg-attention` | LLM / ALG / Attention | LLM / 算法 / 注意力 | `cubes` | variants / mask / kernel | 12 |
| 4 | `cat-py-llm-alg-layer` | LLM / ALG / Layer | LLM / 算法 / 网络层 | `cubes` | ffn / norm / residual / moe | 12 |
| 5 | `cat-py-llm-alg-arch` | LLM / ALG / Architecture | LLM / 算法 / 结构 | `cubes` | config / build / stack | 10 |
| 6 | `cat-py-llm-alg-forward` | LLM / ALG / Forward | LLM / 算法 / 前向与损失 | `code` | forward / loss / backward | 11 |
| 7 | `cat-py-llm-alg-pool` | LLM / ALG / Pool | LLM / 算法 / 池化 | `compact` | token / weighted / attn / norm | 15 |
| 8 | `cat-py-llm-alg-decode` | LLM / ALG / Decode | LLM / 算法 / 解码 | `location-arrow` | search / sample / custom | 10 |
| 9 | `cat-py-llm-alg-optim` | LLM / ALG / Optim | LLM / 算法 / 优化 | `tools` | optimizer / schedule / amp / distributed | 11 |
| 10 | `cat-py-llm-alg-align` | LLM / ALG / Align | LLM / 算法 / 对齐 | `balance-scale` | sft / lora / pref / rl / distill | 12 |
| 11 | `cat-py-llm-alg-quant` | LLM / ALG / Quant | LLM / 算法 / 量化 | `compact` | bnb / format / prune | 10 |
| 12 | `cat-py-llm-alg-analysis` | LLM / ALG / Analysis | LLM / 算法 / 分析 | `search` | attention / embedding / probe / attribution | 10 |
| 13 | `cat-py-llm-alg-experiment` | LLM / ALG / Experiment | LLM / 算法 / 实验 | `chart-line` | seed / config / grid / track | 13 |
| 14 | `cat-py-llm-alg-example` | LLM / ALG / Example | LLM / 算法 / 示例 | `play` | model/* + train/* + run/* | 13 |

**整体设计**：前 6 类是「模型内部」——从文本到 id、到嵌入、到注意力、到层、到整体结构、到前向与损失；第 7 类是「表示收尾」——把 hidden 压成向量；第 8 类是「生成」；第 9~11 类是「训练与压缩」；第 12~13 类是「研究与实验」；第 14 类是「整段可运行模板」。

---

## 二、逐类展开

### 1. `cat-py-llm-alg-tokenize` — LLM / ALG / Tokenize（分词）
**定位**：文本与 token id 的互转，以及词表的构建与扩展。这是 LLM 算法的第一道关，决定模型「看到」什么。
**图标** `font`。子分组 `build` / `special` / `text`，共 12 个。

**`build`（6）— 从零构建分词器**
- `from tokenizers import Tokenizer`：导入 HuggingFace `tokenizers` 核心类。它是底层实现，比 `AutoTokenizer` 更灵活，适合自定义词表。
- `from tokenizers import trainers`：导入训练器模块，含 `BpeTrainer` / `WordPieceTrainer` / `UnigramTrainer`。
- `tokenizer = Tokenizer.from_file("tokenizer.json")`：从已保存文件加载，保留词表与规则，常用于复现实验。
- `tokenizer = Tokenizer(models.BPE())`：新建空 BPE 分词器。BPE 是 GPT 系列用的子词算法。
- `trainer = trainers.BpeTrainer(vocab_size=32000)`：构造 BPE 训练器，`vocab_size=32000` 是目标词表大小，中文常 32k~64k。
- `tokenizer.train_from_iterator(texts, trainer)`：从语料迭代器训练词表。训练后应 `tokenizer.save("tokenizer.json")`。

**`special`（3）— 特殊 token 与扩词表**
- `from tokenizers import Tokenizer`：导入。
- `tokenizer.add_special_tokens(["<pad>", "<eos>"])`：加填充/结束 token。加完必须同步扩模型 embedding。
- `model.resize_token_embeddings(len(tokenizer))`：把模型 embedding 矩阵扩到新词表大小，否则新 token id 越界。

**`text`（4）— 文本与 id 互转**
- `from transformers import AutoTokenizer`：导入高层分词器，适配任意模型。
- `ids = tokenizer.encode(text)`：文本转 id。可加 `add_special_tokens=False`。
- `text = tokenizer.decode(ids)`：id 转文本。可加 `skip_special_tokens=True`。
- `ids = tokenizer.encode(text, truncation=True, max_length=512)`：截断编码，防超长爆显存。

---

### 2. `cat-py-llm-alg-embed` — LLM / ALG / Embedding（嵌入）
**定位**：把 token id 变成向量，并注入位置信息。这是模型「理解」序列的起点。
**图标** `database`。子分组 `token` / `pos` / `init`，共 10 个。

**`token`（4）— token 嵌入**
- `import torch`：导入 PyTorch。
- `import torch.nn as nn`：导入网络模块。
- `emb = nn.Embedding(vocab_size, d_model)`：构造嵌入层，内部是 `vocab_size × d_model` 可学习矩阵。
- `x = emb(tokens) + pos(positions)`：token 嵌入 + 位置嵌入，得到输入表示（`exp`）。

**`pos`（4）— 位置编码**
- `import torch.nn as nn`：导入。
- `pos = nn.Embedding(max_len, d_model)`：绝对位置编码（可学习）。
- `class RoPE(nn.Module):`：RoPE（旋转位置编码）骨架，LLaMA 系列用。
- `class ALiBi(nn.Module):`：ALiBi（线性偏置）骨架，BLOOM 用过。

**`init`（3）— 初始化与缩放**
- `import torch.nn as nn`：导入。
- `nn.init.normal_(emb.weight, std=0.02)`：正态初始化，GPT 系列常用。
- `x = x * (d_model ** 0.5)`：嵌入缩放，平衡嵌入与位置编码量级（`exp`）。

---

### 3. `cat-py-llm-alg-attention` — LLM / ALG / Attention（注意力）
**定位**：token 之间如何「互相看」。这是 Transformer 的核心，也是研究最活跃的地方。
**图标** `cubes`。子分组 `variants` / `mask` / `kernel`，共 12 个。

**`variants`（5）— 注意力变体**
- `import torch`：导入。
- `import torch.nn as nn`：导入。
- `class MHA(nn.Module):`：多头注意力骨架，每头独立 q/k/v。
- `class MQA(nn.Module):`：多查询注意力骨架，所有头共享 k/v，省 KV cache，PaLM 用。
- `class GQA(nn.Module):`：分组查询注意力骨架，q 多组、k/v 少组，LLaMA2/3 用，是 MHA 与 MQA 的折中。

**`mask`（3）— 掩码**
- `import torch`：导入。
- `mask = torch.triu(torch.ones(L, L), diagonal=1).bool()`：因果掩码，位置 i 只能看 ≤ i。
- `sliding_window = 4096`：滑动窗口，每 token 只看前 4096 个，Mistral 用（`exp`）。

**`kernel`（4）— 高效核**
- `import torch`：导入。
- `attn = torch.softmax(scores / scale, dim=-1)`：标准 softmax 注意力。
- `from flash_attn import flash_attn_func`：FlashAttention，融合 CUDA kernel，省显存提速。
- `out = flash_attn_func(q, k, v, causal=True)`：调用 FlashAttention，`causal=True` 表示因果掩码。

---

### 4. `cat-py-llm-alg-layer` — LLM / ALG / Layer（网络层）
**定位**：Transformer block 里的组件——FFN、归一化、残差、MoE。决定模型的「表达能力」。
**图标** `cubes`。子分组 `ffn` / `norm` / `residual` / `moe`，共 12 个。

**`ffn`（4）— 前馈网络**
- `import torch.nn as nn`：导入。
- `class MLP(nn.Module):`：标准 FFN 骨架（Linear → 激活 → Linear）。
- `class SwiGLU(nn.Module):`：SwiGLU 骨架，LLaMA 系列用，效果优于 ReLU/GELU。
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

### 5. `cat-py-llm-alg-arch` — LLM / ALG / Architecture（结构）
**定位**：把层堆成模型，改配置、建模型、遍历层。这是「模型级」操作。
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

### 6. `cat-py-llm-alg-forward` — LLM / ALG / Forward（前向与损失）
**定位**：一次前向怎么算、损失怎么定义、梯度怎么回传。这是「训练信号」的来源。
**图标** `code`。子分组 `forward` / `loss` / `backward`，共 11 个。

**`forward`（3）— 前向**
- `import torch`：导入。
- `def forward(self, x):`：forward 骨架（多行）。
- `logits = self.lm_head(hidden)`：出 logits（`exp`）。

**`loss`（5）— 损失函数**
- `import torch.nn.functional as F`：导入函数式接口。
- `loss = F.cross_entropy(logits.view(-1, V), labels.view(-1))`：交叉熵，`V` 是词表大小。
- `loss = F.cross_entropy(logits, labels, label_smoothing=0.1)`：label smoothing，防过拟合。
- `loss = F.kl_div(log_probs, target_probs)`：KL 散度，蒸馏/RLHF 用，输入是 log 概率。
- `loss = contrastive_loss(z1, z2)`：对比损失（`exp`）。

**`backward`（3）— 反向**
- `import torch`：导入。
- `loss.backward()`：反向传播。
- `grad = torch.autograd.grad(loss, emb)[0]`：取指定张量梯度，归因分析用。

---

### 7. `cat-py-llm-alg-pool` — LLM / ALG / Pool（池化）
**定位**：把 `[batch, seq, hidden]` 压成 `[batch, hidden]`，得到句向量。这是「表示 → 向量」的收尾，embedding 模型、RAG、句相似度的关键一步。
**图标** `compact`。子分组 `token` / `weighted` / `attn` / `norm`，共 15 个。

**`token`（5）— token 维池化**
- `import torch`：导入。
- `vec = hidden.mean(dim=1)`：mean pooling，对序列维取平均，最常用的句向量池化。
- `vec = hidden[:, 0]`：CLS pooling，取 `[CLS]` 位置，BERT 分类常用。
- `vec = hidden[:, -1]`：last-token pooling，取最后一个 token，E5/GTE 等 decoder 句向量常用。
- `vec = hidden.max(dim=1).values`：max pooling，对序列维取最大，文本分类常用。

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

### 8. `cat-py-llm-alg-decode` — LLM / ALG / Decode（解码）
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
- `class MyLogitsProcessor(LogitsProcessor):`：自定义约束解码骨架（多行）。
- `from transformers import AssistedGenerationCandidateGenerator`：投机解码，小模型草稿、大模型验证，提速。

---

### 9. `cat-py-llm-alg-optim` — LLM / ALG / Optim（优化）
**定位**：参数怎么更新。优化器、学习率调度、混合精度、分布式，决定训练效率与稳定性。
**图标** `tools`。子分组 `optimizer` / `schedule` / `amp` / `distributed`，共 11 个。

**`optimizer`（3）— 优化器**
- `import torch`：导入。
- `from torch.optim import AdamW`：AdamW，Transformer 标配（Adam + 权重衰减解耦）。
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

### 10. `cat-py-llm-alg-align` — LLM / ALG / Align（对齐）
**定位**：让模型「听话」。SFT、LoRA、偏好对齐、RLHF、蒸馏，是后训练的核心。
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
- `from trl import PPOTrainer`：PPO/RLHF，经典 RLHF 算法，需 reward model。
- `from trl import RewardTrainer`：训练 reward model。

**`distill`（2）— 蒸馏**
- `import torch.nn.functional as F`：导入。
- `kd_loss = alpha * ce_loss + (1 - alpha) * kl_loss`：蒸馏损失（`exp`），`alpha` 平衡硬/软标签。

---

### 11. `cat-py-llm-alg-quant` — LLM / ALG / Quant（量化）
**定位**：把模型压小。低比特、量化格式、剪枝，决定模型能否在有限显存/边缘设备跑。
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

### 12. `cat-py-llm-alg-analysis` — LLM / ALG / Analysis（分析）
**定位**：模型「为什么这样输出」。注意力可视化、嵌入降维、探针、归因，是研究者的显微镜。
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
- `vec = hidden.mean(dim=1)`：先取句向量再做降维，是嵌入可视化的常见前置。

**`probe`（2）— 线性探针**
- `import torch.nn as nn`：导入。
- `probe = nn.Linear(hidden_size, n_classes)`：线性探针，在冻结表示上训分类器，测表示质量。

**`attribution`（3）— 归因**
- `import torch`：导入。
- `grad = torch.autograd.grad(loss, emb)[0]`：取嵌入梯度。
- `importance = (grad * emb).sum(-1)`：梯度×输入归因（`exp`），衡量每 token 重要性。

---

### 13. `cat-py-llm-alg-experiment` — LLM / ALG / Experiment（实验）
**定位**：让实验可复现、可对比。种子、配置、网格、记录，是算法研究的「实验台」。
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

### 14. `cat-py-llm-alg-example` — LLM / ALG / Example（示例）
**定位**：整段可运行模板，拖进去改默认值即可。这是「从片段到可跑」的桥。
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

`torch`、`transformers`、`tokenizers`、`peft`、`trl`、`datasets`、`bitsandbytes`、`auto-gptq`、`awq`、`llama-cpp-python`、`flash-attn`、`matplotlib`、`scikit-learn`。

## 四、使用建议

- **前 7 类**（Tokenize → Pool）是「模型内部」，适合改结构、做研究。
- **第 8 类**（Decode）是「生成」，调参数即可。
- **第 9~11 类**（Optim / Align / Quant）是「训练与压缩」，工程性强。
- **第 12~13 类**（Analysis / Experiment）是「研究工具」，配合使用。
- **第 14 类**（Example）是「整段模板」，拖进去改默认值即可跑，是入门与验证的首选。
