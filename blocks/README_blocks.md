# Scratch 系列编辑器积木文件汇总

本文介绍 `blocks/` 中的核心积木定义、扩展积木集和其他可导入的积木数据。分类数按 JSON 顶层数组统计；积木数按各分类 `subgroups` 下的积木数组统计。相同核心积木的不同语言版本只计一次。

## 总览

| 用途 | 积木集 | 分类数 | 积木数 |
|---|---|---:|---:|
| ScratchVerilog 扩展 | SystemVerilog | 20 | 187 |
| ScratchVerilog 核心 | Verilog / SystemVerilog | 10 | 129 |
| ScratchCpp 扩展 | C++、STL、GTK 2.3.4、竞赛编程、Arduino | 52 | 771 |
| ScratchCpp 核心 | C/C++（英文、中文及 i18n 版本） | 7 | 134 |
| ScratchPython 扩展 | AI 应用、LLM 应用、LLM 算法 | 47 | 494 |
| ScratchPython 核心 | Python | 9 | 88 |
| Shell 积木数据 | Shell / C Shell | 11 | 314 |
| 拼音及中文输入数据 | 拼音、词语和中文整句 | 26 | 8,202 |

扩展积木通常是可插入编辑器的代码片段，不等同于完整程序；使用时应根据目标语言和所用库补齐上下文、依赖与初始化代码。Shell 和拼音文件是符合积木 JSON 结构的数据集；是否能直接加载取决于目标编辑器支持的语言和配置。

## ScratchVerilog

### SystemVerilog 扩展

[scratchverilog_sv_json_20261106_4e986c.json](./scratchverilog_sv_json_20261106_4e986c.json) 包含 20 类、187 个积木，覆盖 RTL 编写、验证和 UVM 常用结构。

| 分类 | 积木数 |
|---|---:|
| SV File and Preprocessor | 7 |
| SV Package and Import | 4 |
| SV Data Declaration | 13 |
| SV Module and Interface | 5 |
| SV Port and Connection | 6 |
| SV Procedural Block | 6 |
| SV Statement and Control Flow | 17 |
| SV Task and Function | 4 |
| SV Class and OOP | 11 |
| SV Assertion and Coverage | 9 |
| SV Generate and Parameterization | 5 |
| SV Expression and Operator | 28 |
| SV System Function | 14 |
| SV DPI and External | 4 |
| SV UVM Base | 11 |
| SV UVM Component | 9 |
| SV UVM Sequence | 9 |
| SV UVM Config and Factory | 7 |
| SV UVM TLM | 7 |
| SV UVM Phase | 11 |

### 核心 Verilog 积木

[scratchverilog_blocks_i18n.json](./scratchverilog_blocks_i18n.json) 是核心语言积木的本地化定义，包含 10 类、129 个积木，涵盖指令/预处理、模块/端口、Always/Initial、模拟块、控制、赋值、运算符/表达式、数学/模拟函数、系统任务和测试平台。

## ScratchCpp

### C++ 与平台/库扩展

| 文件 | 分类数 | 积木数 | 主要内容 |
|---|---:|---:|---|
| [scratchcpp_cpp_json_20261102_d7972f.json](./scratchcpp_cpp_json_20261102_d7972f.json) | 12 | 98 | C++ 预处理、命名空间、类型、全局变量、函数、类、main、语句、控制、指针/引用、IO、异常 |
| [scratchcpp_cppstl_json_20261102_5b5104.json](./scratchcpp_cppstl_json_20261102_5b5104.json) | 13 | 137 | STL 容器、算法、迭代器、二分查找、排列及工具 |
| [scratchcpp_gtk234_json_20261102_61c367.json](./scratchcpp_gtk234_json_20261102_61c367.json) | 9 | 322 | GTK 初始化、窗口、控件、布局、菜单/工具栏、文本/树、信号、对话框及杂项 |
| [scratchcpp_ol_json_20261102_535ba7.json](./scratchcpp_ol_json_20261102_535ba7.json) | 9 | 102 | 竞赛模板、快速 IO、位运算、数学、DP、图、数据结构、字符串、技巧 |
| [scratchcpp_oladv_json_20261102_e42d38.json](./scratchcpp_oladv_json_20261102_e42d38.json) | 6 | 37 | 进阶图论、字符串、数学、DP、数据结构及其他技巧 |
| [scratchcpp_arduino_json_20261101.json](./scratchcpp_arduino_json_20261101.json) | 3 | 75 | Arduino C++、Setup 初始化、Loop 主循环；包括引脚 IO、串口、总线、舵机、EEPROM、计时等 |

### 核心 C/C++ 积木与本地化

[scratchcpp_blocks_en.json](./scratchcpp_blocks_en.json)、[scratchcpp_blocks_zh.json](./scratchcpp_blocks_zh.json) 和 [scratchcpp_blocks_i18n.json](./scratchcpp_blocks_i18n.json) 是同一套核心积木的不同文本版本，各包含 7 类、134 个积木，不应将三份的数量相加。内容包括预处理、函数、变量、控制流、常用函数、数学和字符串。

## ScratchPython

### Python 扩展

| 文件 | 分类数 | 积木数 | 主要内容 |
|---|---:|---:|---|
| [scratchpython_aiapp_json_20261109_18a123.json](./scratchpython_aiapp_json_20261109_18a123.json) | 13 | 112 | AI 客户端、Prompt、聊天、工具调用、结构化输出、Embedding、RAG、工具函数、图像、语音、多模态、Agent、评测 |
| [scratchpython_llm_json_20261109_e78e12.json](./scratchpython_llm_json_20261109_e78e12.json) | 14 | 146 | 分词器、数据、本地模型、推理、训练、对齐、提示工程、评测、框架、向量库、部署、缓存、安全、可观测 |
| [scratchpython_llmalg_json_20261110_c145cf.json](./scratchpython_llmalg_json_20261110_c145cf.json) | 20 | 236 | 数据、分词、嵌入、初始化、注意力、长上下文、网络层、模型结构、前向与损失、训练目标、池化、解码、优化、调度、正则化、对齐、量化、分析、实验、示例 |

### 核心 Python 积木

[scratchpython_blocks_i18n.json](./scratchpython_blocks_i18n.json) 是核心 Python 积木的本地化定义，包含 9 类、88 个积木：导入、函数、类、基础/注释、变量、容器、字符串、控制流和文件。

## 其他积木数据

### Shell

[scratchshell_blocks_i18n.json](./scratchshell_blocks_i18n.json) 包含 11 类、314 个 Shell / C Shell 积木，包括脚本头、参数、变量、环境变量、数组/列表、运算符/测试、替换/展开、控制、函数/别名、输入输出和常用命令。

### 拼音与中文输入

[pinyin_blocks.json](./pinyin_blocks.json) 包含 26 类、8,202 个数据项，按零声母及声母分类收录带声调的汉字拼音，并提供双字词、三字词、四字词和中文整句。示例标签包括 `啊 (a5)` 和 `中国 (zhong1guo2)`。该文件是拼音/中文输入数据，不是编程语言代码片段集合。

## 配套说明与生成提示

- Python 扩展说明：[scratchpython_aiapp_json_20261109_18a123.md](./scratchpython_aiapp_json_20261109_18a123.md)、[scratchpython_llm_json_20261109_e78e12.md](./scratchpython_llm_json_20261109_e78e12.md)、[scratchpython_llmalg_json_20261110_c145cf.md](./scratchpython_llmalg_json_20261110_c145cf.md)。这些说明文件的统计可能滞后；本页数量按对应 JSON 重新统计。
- 生成提示文件：`scratchcpp_block_json_ai_prompt*.txt`、`scratchpython_block_json_ai_prompt.txt`、`scratchverilog_block_json_ai_prompt.txt`，用于积木内容的设计或生成，不是编辑器加载的积木定义。

## JSON 结构说明

积木 JSON 通常是分类数组。分类包含 `id`、`category`、`icon`、`collapsed` 和 `subgroups`；本地化文件还可能包含 `category_i18n`。子分组中的积木包含唯一标识 `id`、显示用 `label`、插入编辑器的 `code`、图标 `icon` 和插入模式 `mode`。常见模式为 `line`（语句或代码结构）和 `exp`（表达式）。多行代码模板可能预留缩进位置，实际使用时应留意插入光标位置及依赖。
