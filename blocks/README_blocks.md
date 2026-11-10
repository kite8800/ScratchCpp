# ScratchVerilog / ScratchCpp / ScratchPython 积木文件汇总

本文汇总 `blocks/` 中供 ScratchVerilog、ScratchCpp 和 ScratchPython 编辑器使用的积木定义、扩展积木集及配套资料。积木数量按 JSON 中各分类 `subgroups` 下的积木数组统计；同一份积木的语言版本不重复计入扩展总数。

## 总览

| 编辑器 | 扩展积木集 | 扩展分类数 | 扩展积木数 | 核心积木 |
|---|---|---:|---:|---|
| ScratchVerilog | SystemVerilog | 20 | 187 | 10 类，129 个 |
| ScratchCpp | C++、STL、GTK 2.3.4、竞赛编程、Arduino | 52 | 771 | 7 类，134 个；提供英文、中文及 i18n 版本 |
| ScratchPython | AI 应用、LLM 应用、LLM 算法 | 41 | 428 | 9 类，88 个 |

扩展积木主要是可插入编辑器的代码片段，不等同于完整程序；使用时应根据目标语言和所用库补齐上下文、依赖与初始化代码。

## ScratchVerilog

### SystemVerilog 扩展

文件：[scratchverilog_sv_json_20261106_4e986c.json](./scratchverilog_sv_json_20261106_4e986c.json)，包含 20 类、187 个积木，覆盖 RTL 编写、验证和 UVM 常用结构。

| 分类 | 积木数 | 内容 |
|---|---:|---|
| SV File and Preprocessor | 7 | 文件、编译指令与预处理 |
| SV Package and Import | 4 | Package、类型和符号导入 |
| SV Data Declaration | 13 | 数据类型、变量与声明 |
| SV Module and Interface | 5 | Module、Interface 定义 |
| SV Port and Connection | 6 | 端口与模块连接 |
| SV Procedural Block | 6 | 过程块 |
| SV Statement and Control Flow | 17 | 语句、条件与循环控制 |
| SV Task and Function | 4 | Task 与 Function |
| SV Class and OOP | 11 | Class 与面向对象结构 |
| SV Assertion and Coverage | 9 | 断言与覆盖率 |
| SV Generate and Parameterization | 5 | Generate 与参数化 |
| SV Expression and Operator | 28 | 表达式及运算符 |
| SV System Function | 14 | 系统函数 |
| SV DPI and External | 4 | DPI 与外部接口 |
| SV UVM Base | 11 | UVM 基础类 |
| SV UVM Component | 9 | UVM 组件 |
| SV UVM Sequence | 9 | UVM Sequence |
| SV UVM Config and Factory | 7 | 配置与 Factory |
| SV UVM TLM | 7 | TLM 通信 |
| SV UVM Phase | 11 | UVM 仿真阶段 |

### 核心 Verilog 积木

[scratchverilog_blocks_i18n.json](./scratchverilog_blocks_i18n.json) 是核心语言积木的中英文本地化定义，包含 10 类、129 个积木：指令/预处理、模块/端口、Always/Initial、模拟块、控制、赋值、运算符/表达式、数学/模拟函数、系统任务和测试平台。

## ScratchCpp

### C++ 与平台/库扩展

| 文件 | 分类数 | 积木数 | 主要内容 |
|---|---:|---:|---|
| [scratchcpp_cpp_json_20261102_d7972f.json](./scratchcpp_cpp_json_20261102_d7972f.json) | 12 | 98 | C++ 预处理、命名空间、类型、全局变量、函数、类、main、语句、控制、指针/引用、IO、异常 |
| [scratchcpp_cppstl_json_20261102_5b5104.json](./scratchcpp_cppstl_json_20261102_5b5104.json) | 13 | 137 | STL Vector、String、Map、Set、Stack/Queue、Deque/List、Unordered、Bitset、二分查找、算法、排列、迭代器、Utility |
| [scratchcpp_gtk234_json_20261102_61c367.json](./scratchcpp_gtk234_json_20261102_61c367.json) | 9 | 322 | GTK 初始化、窗口、控件、布局、菜单/工具栏、文本/树、信号、对话框及杂项 |
| [scratchcpp_ol_json_20261102_535ba7.json](./scratchcpp_ol_json_20261102_535ba7.json) | 9 | 102 | 竞赛模板、快速 IO、位运算、数学、DP、图、数据结构、字符串、技巧 |
| [scratchcpp_oladv_json_20261102_e42d38.json](./scratchcpp_oladv_json_20261102_e42d38.json) | 6 | 37 | 进阶图论、字符串、数学、DP、数据结构及其他技巧 |
| [scratchcpp_arduino_json_20261101.json](./scratchcpp_arduino_json_20261101.json) | 3 | 75 | Arduino C++、Setup 初始化、Loop 主循环；包含引脚 IO、串口、总线、舵机、EEPROM、计时等 |

### 核心 C/C++ 积木与本地化

[scratchcpp_blocks_en.json](./scratchcpp_blocks_en.json)、[scratchcpp_blocks_zh.json](./scratchcpp_blocks_zh.json) 和 [scratchcpp_blocks_i18n.json](./scratchcpp_blocks_i18n.json) 是同一套核心积木的不同文本版本，各包含 7 类、134 个积木，不应将三份的数量相加。内容包括预处理、函数、变量、控制流、常用函数、数学和字符串。

## ScratchPython

### Python 扩展

| 文件 | 分类数 | 积木数 | 主要内容 |
|---|---:|---:|---|
| [scratchpython_aiapp_json_20261109_18a123.json](./scratchpython_aiapp_json_20261109_18a123.json) | 13 | 112 | AI 客户端、Prompt、聊天、工具调用、结构化输出、Embedding、RAG、工具函数、图像、语音、多模态、Agent、评测 |
| [scratchpython_llm_json_20261109_e78e12.json](./scratchpython_llm_json_20261109_e78e12.json) | 14 | 146 | 分词器、数据、本地模型、推理、训练、对齐、提示工程、评测、框架、向量库、部署、缓存、安全、可观测 |
| [scratchpython_llmalg_json_20261110_c145cf.json](./scratchpython_llmalg_json_20261110_c145cf.json) | 14 | 170 | 分词、嵌入、注意力、网络层、模型结构、前向/损失、池化、解码、优化、对齐、量化、分析、实验、示例 |

### 核心 Python 积木

[scratchpython_blocks_i18n.json](./scratchpython_blocks_i18n.json) 是核心 Python 积木的本地化定义，包含 9 类、88 个积木：导入、函数、类、基础/注释、变量、容器、字符串、控制流和文件。

## 配套说明与生成提示

- Python 扩展说明：[scratchpython_aiapp_json_20261109_18a123.md](./scratchpython_aiapp_json_20261109_18a123.md)、[scratchpython_llm_json_20261109_e78e12.md](./scratchpython_llm_json_20261109_e78e12.md)、[scratchpython_llmalg_json_20261110_c145cf.md](./scratchpython_llmalg_json_20261110_c145cf.md)。
- 生成提示文件：`scratchcpp_block_json_ai_prompt*.txt`、`scratchpython_block_json_ai_prompt.txt`、`scratchverilog_block_json_ai_prompt.txt`，用于积木内容的设计/生成，不是编辑器加载的积木定义。

注意：配套 Markdown 的汇总数字可能与当前 JSON 不一致；本文件中的分类数和积木数以对应 JSON 实际内容为准。

## JSON 结构说明

扩展 JSON 通常是分类数组。分类包含 `id`、`category`、`icon`、`collapsed` 和 `subgroups`；子分组中的积木包含唯一标识 `id`、显示用 `label`、插入编辑器的 `code`、图标 `icon` 和插入模式 `mode`。常见模式为 `line`（语句或代码结构）和 `exp`（表达式）。多行代码模板可能预留缩进位置，实际使用时应留意其插入光标位置及依赖。
