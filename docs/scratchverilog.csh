#!/bin/csh -f
# scratchverilog.csh — 同目录 ScratchVerilog 编辑器的 csh / tcsh 入口
#
# csh 里做 UTF-8 百分号编码（中文路径、空格、# 号）太容易出错，
# 所以这里只做转发：找 bash（没有就退到 sh）执行 scratchverilog.sh，
# 保证 csh 版与 bash 版行为完全一致，不用维护两套编码逻辑。
#
# 用法：
#   ./scratchverilog.csh                    打开编辑器
#   ./scratchverilog.csh ~/code/demo.v      打开指定文件
#   ./scratchverilog.csh --file ~/code/demo.v   同上，显式写 --file
#   （首次使用先 chmod +x scratchverilog.csh scratchverilog.sh）
#
# 用哪个浏览器、怎么传文件，全在 scratchverilog.sh 里决定：
#   Chromium 系 —— --app 无地址栏窗口 + ?file= 读入文件
#   Firefox     —— 只打开编辑器（没有 --app，也读不了命令行文件，会提示一句）
# 这里只是转发，所以 csh 版和 bash 版行为永远一致，不用维护两套编码逻辑。

# $0:h 是 csh 的路径修饰符（取目录部分），比 `dirname $0` 更安全：
# 不受命令替换分词影响，目录名带空格也不会散架
set here = "$0:h"
if ( "$here" == "" ) set here = "."
if ( "$here" == "$0" ) set here = "."
set runner_file = "$here/scratchverilog.sh"

if ( ! -f "$runner_file" ) then
    echo "找不到 $runner_file"
    echo "请把 scratchverilog.csh 与 scratchverilog.sh 放在同一目录。"
    exit 1
endif

# 只认 bash：scratchverilog.sh 用了 bash 语法（${s:i:1} 切片、printf -v），sh/dash 跑不了
# 先按常见路径找，避开 csh 里反引号套单引号的引号地狱；都没有才退回 PATH
set bashbin = ""
if ( -x /bin/bash ) set bashbin = "/bin/bash"
if ( "$bashbin" == "" ) then
    if ( -x /usr/bin/bash ) set bashbin = "/usr/bin/bash"
endif
if ( "$bashbin" == "" ) then
    if ( -x /usr/local/bin/bash ) set bashbin = "/usr/local/bin/bash"
endif
if ( "$bashbin" == "" ) then
    set bashbin = "`command -v bash`"
endif
if ( "$bashbin" == "" ) then
    echo "没找到 bash。scratchverilog.csh 只是转发壳，实际逻辑在 scratchverilog.sh 里，需要 bash 执行。"
    echo "请先安装 bash（多数系统包名叫 bash），再重试。"
    exit 1
endif

exec "$bashbin" "$runner_file" $argv:q
