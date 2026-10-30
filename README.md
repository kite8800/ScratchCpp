# ScratchCpp

A scratch-like block editor for C/CPP/C++, with extensible customized block editing feature.

# Block C/C++ Editor

A browser-based block editor for learning C/C++. Beginners drag ready-made code blocks (variables, loops, `printf`, `cout`, math functions, string handling…) into a syntax-highlighted editor instead of typing everything from scratch. C and C++ are supported side by side, with configurable blocks that can be extended, reordered, and shared as JSON.

No installation, no build step — just open `ScratchCpp.html`.

## Why this exists

Writing C/C++ from scratch is intimidating for beginners — one missing semicolon or bracket and nothing compiles. This editor lets learners assemble programs by dragging blocks, while still allowing them to type and edit code directly. Blocks are organized by category, split into C / C++ / custom subgroups, and cover the common cases (declarations, control flow, IO, math, strings).

## Features

- **Block palette** — 7 categories, each with `none` / `c` / `cpp` subgroups plus optional custom subgroups. Click to insert at the current line, drag to insert at a specific position.
- **Editor** — C/C++ syntax highlighting (Prism), smart indent, auto-indent, find & replace, undo/redo, optional line numbers.
- **Two insert modes** — `Line` (insert at line start, keep indent) or `Exp` (insert at cursor as an expression, optional semicolon stripping).
- **C vs C++** — `std::` prefix can be stripped globally with one checkbox.
- **Configurable** — add, edit, delete, reorder blocks and categories; custom icon per block; import/export the whole config as JSON; merge-import; restore defaults. Persisted in `localStorage`.
- **Files** — open `.c/.cpp/.h/.hpp/.cc/.txt`, save with the title as the filename, clipboard import/export with fallback.
- **Zero font dependencies** — icons are inline SVG.

## Getting Started

Open `ScratchCpp.html` in a modern browser (Chrome, Edge, Firefox, Safari). Prism.js is loaded from CDN.

----

# 积木 C/C++ 编辑器

一个面向 C/C++ 初学者的浏览器端积木式代码编辑器。初学者不用从零敲代码，而是把现成的代码积木（变量、循环、`printf`、`cout`、数学函数、字符串处理……）拖进带语法高亮的编辑器。同时支持 C 和 C++，积木可自定义、可排序、可导出为 JSON 分享。

无需安装、无需构建，打开 `ScratchCpp.html` 就能用。

## 为什么做这个

手写 C/C++ 对初学者很不友好——漏一个分号或括号就编译不过。这个编辑器让学习者通过拖积木拼出程序，同时保留直接手写和修改代码的能力。积木按分类组织，拆分为 C / C++ / 自定义子类别，覆盖常见场景（声明、控制流、IO、数学、字符串）。

## 功能

- **积木面板** — 7 个分类，每个含 `none` / `c` / `cpp` 子类别，可追加自定义子类别。点击插入到当前行，拖拽插入到指定位置。
- **编辑器** — C/C++ 语法高亮（Prism）、智能缩进、自动缩进、查找替换、撤销重做、可选行号。
- **两种插入模式** — `Line`（插入到行首，保留缩进）或 `Exp`（插入到光标处作为表达式，可选去末尾分号）。
- **C 与 C++** — 一个开关全局去掉 `std::` 前缀。
- **可配置** — 增删改序积木和分类；每个积木可自定义图标；整套配置导入导出 JSON、增量合并、恢复默认。持久化在 `localStorage`。
- **文件** — 打开 `.c/.cpp/.h/.hpp/.cc/.txt`，用标题作为文件名保存，剪贴板导入导出带兜底。
- **零字体依赖** — 图标全部内联 SVG。

## 快速开始

用现代浏览器（Chrome、Edge、Firefox、Safari）打开 `ScratchCpp.html`。Prism.js 从 CDN 加载。

----

# Customized Block

It is easy to add customized blocks for Arduino etc.

## Block Configuration

Blocks are stored as a JSON array of categories:

```json
[
  {
    "id": "cat-var",
    "category": "变量",
    "icon": "database",
    "collapsed": false,
    "subgroups": {
      "none": [
        {
          "id": "v-int",
          "icon": "hashtag",
          "label": "int x = 10;",
          "code": "int x = 10;",
          "mode": "line"
        }
      ],
      "c": [],
      "cpp": []
    }
  }
]## 积木配置格式

积木存为分类数组的 JSON：

```json
[
  {
    "id": "cat-var",
    "category": "变量",
    "icon": "database",
    "collapsed": false,
    "subgroups": {
      "none": [
        {
          "id": "v-int",
          "icon": "hashtag",
          "label": "int x = 10;",
          "code": "int x = 10;",
          "mode": "line"
        }
      ],
      "c": [],
      "cpp": []
    }
  }
]
```

**分类** — `id`、`category`、`icon`、`collapsed`、`subgroups`。`subgroups` 必须含 `none` / `c` / `cpp`（可为空数组）；追加的键成为自定义子类别。

**积木** — `id`、`icon`、`label`、`code`、`mode`。
- `mode: "line"` — 插入到当前行行首，保留缩进。
- `mode: "lc"` — 插入到光标处作为表达式（UI 中叫 `Exp`）。

**C++ `std::` 前缀** — 在 `code` / `label` 里写 `{{STD}}`，会根据「省略 std::」开关替换为 `std::` 或空串。

**图标**（不带 `fa-` 前缀）：`cube` `folder` `database` `code` `code-branch` `terminal` `calculator` `font` `file-import` `star` `bolt` `tools` `hashtag` `list` `equals` `plus` `minus` `times` `divide` `percent` `play` `print` `keyboard` `search` `link` `cut` `copy` `exchange-alt` `sign-out-alt` `globe` `arrow-up` `arrow-down` `arrow-right` `location-arrow` `cubes` `square-root-alt` `circle` `wave-square` `chart-line` `absolute` `superscript` `exclamation-triangle` `quote-left` `ruler-horizontal` `balance-scale` `file-signature` `stop` `forward` `redo`

```

**Category** — `id`, `category`, `icon`, `collapsed`, `subgroups`. `subgroups` must contain `none` / `c` / `cpp` (can be empty arrays); additional keys become custom subgroups.

**Block** — `id`, `icon`, `label`, `code`, `mode`.
- `mode: "line"` — insert at the start of the current line, preserve indentation.
- `mode: "lc"` — insert at the cursor as an expression (labelled `Exp` in the UI).

**C++ `std::` prefix** — write `{{STD}}` in `code` / `label`; it's replaced with `std::` or empty string based on the "omit std::" checkbox.

**Icons** (no `fa-` prefix): `cube` `folder` `database` `code` `code-branch` `terminal` `calculator` `font` `file-import` `star` `bolt` `tools` `hashtag` `list` `equals` `plus` `minus` `times` `divide` `percent` `play` `print` `keyboard` `search` `link` `cut` `copy` `exchange-alt` `sign-out-alt` `globe` `arrow-up` `arrow-down` `arrow-right` `location-arrow` `cubes` `square-root-alt` `circle` `wave-square` `chart-line` `absolute` `superscript` `exclamation-triangle` `quote-left` `ruler-horizontal` `balance-scale` `file-signature` `stop` `forward` `redo`

----

# 定制积木

非常容易扩展和定制积木模块

## 积木配置格式

积木存为分类数组的 JSON：

```json
[
  {
    "id": "cat-var",
    "category": "变量",
    "icon": "database",
    "collapsed": false,
    "subgroups": {
      "none": [
        {
          "id": "v-int",
          "icon": "hashtag",
          "label": "int x = 10;",
          "code": "int x = 10;",
          "mode": "line"
        }
      ],
      "c": [],
      "cpp": []
    }
  }
]
```

**分类** — `id`、`category`、`icon`、`collapsed`、`subgroups`。`subgroups` 必须含 `none` / `c` / `cpp`（可为空数组）；追加的键成为自定义子类别。

**积木** — `id`、`icon`、`label`、`code`、`mode`。
- `mode: "line"` — 插入到当前行行首，保留缩进。
- `mode: "lc"` — 插入到光标处作为表达式（UI 中叫 `Exp`）。

**C++ `std::` 前缀** — 在 `code` / `label` 里写 `{{STD}}`，会根据「省略 std::」开关替换为 `std::` 或空串。

**图标**（不带 `fa-` 前缀）：`cube` `folder` `database` `code` `code-branch` `terminal` `calculator` `font` `file-import` `star` `bolt` `tools` `hashtag` `list` `equals` `plus` `minus` `times` `divide` `percent` `play` `print` `keyboard` `search` `link` `cut` `copy` `exchange-alt` `sign-out-alt` `globe` `arrow-up` `arrow-down` `arrow-right` `location-arrow` `cubes` `square-root-alt` `circle` `wave-square` `chart-line` `absolute` `superscript` `exclamation-triangle` `quote-left` `ruler-horizontal` `balance-scale` `file-signature` `stop` `forward` `redo`

