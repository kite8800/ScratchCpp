#!/usr/bin/env bash
# scratchverilog — 用 Edge / Chrome 的 --app 窗口打开同目录下的 ScratchVerilog 编辑器
#                   只有 Firefox 时退化为普通窗口（不支持 --app，也读不了命令行文件）
#
# 用法：
#   ./scratchverilog.sh                      打开编辑器（默认示例代码）
#   ./scratchverilog.sh ~/code/demo.v        打开指定文件
#   ./scratchverilog.sh --file ~/code/demo.v 同上，显式写 --file
#   ./scratchverilog.sh ./demo.v             相对路径也行
#   SCRATCHVERILOG_BROWSER=/path/chrome ./scratchverilog.sh   指定浏览器
#
# 浏览器分工：
#   Chromium 系（Edge / Chrome / Chromium / Brave）
#       用 --app 开无地址栏窗口，靠 ?file= + fetch 把文件读进编辑器。
#   Firefox
#       没有 --app，也没有 --allow-file-access-from-files 的对应物；
#       且 file:// 页面不允许 fetch 本地文件，所以只打开 index.html，
#       传了文件也不读，只在终端提示一句（不报错）。
#
# 为什么要 --allow-file-access-from-files：
#   页面用 fetch('file:///...') 读你指定的文件，Chrome/Edge 默认禁止 file:// 页面读本地文件。
# 为什么要 --user-data-dir：
#   把这条放行限制关在独立配置目录里，不波及日常浏览器。
#   附带效果：主题、语言、缩进设置都存在这里，所有窗口共享（首次打开是默认配置）。
#
# 已知限制（不影响正常使用）：
#   snap 版 chromium 有私有 /tmp，看不到真实 /tmp 下的文件。
#   要把文件放在 $HOME 等常规目录，否则页面会提示打开失败。

set -u

SELF_DIR=$(cd -- "$(dirname "$0")" && pwd -P) || exit 1
HTML_PATH="$SELF_DIR/index.html"

if [ ! -f "$HTML_PATH" ]; then
    echo "找不到 index.html：$HTML_PATH" >&2
    echo "请把 scratchverilog.sh 放在与 index.html 同一目录。" >&2
    exit 1
fi

PROFILE_DIR="${SCRATCHVERILOG_PROFILE:-${XDG_CONFIG_HOME:-$HOME/.config}/scratchverilog/profile}"

usage() {
    cat <<'EOF'
用法：
  ./scratchverilog.sh                      打开编辑器（默认示例代码）
  ./scratchverilog.sh ~/code/demo.v        打开指定文件
  ./scratchverilog.sh --file ~/code/demo.v 同上，显式写 --file
  ./scratchverilog.sh ./demo.v             相对路径也行

环境变量：
  SCRATCHVERILOG_BROWSER   指定浏览器可执行文件（默认自动找 Edge/Chrome/Chromium，最后才用 Firefox）
  SCRATCHVERILOG_PROFILE   指定 profile 目录（默认 $XDG_CONFIG_HOME 或 ~/.config 下的 scratchverilog/profile）

选项：
  --file, -f <路径>        要打开的文件（也可以直接当位置参数给）
  --dry-run, -n            只打印将要执行的命令，不启动浏览器
  -h, --help               显示本帮助

注意：Firefox 没有 --app 窗口，也不能在命令行读入本地文件，
      只有 Firefox 时只打开编辑器，传了文件会在终端提示一句。
EOF
}

# 百分号编码：$2=1 时保留 '/'（路径用），否则连 '/' 一起编码（query 参数用）
uri_escape() {
    local LC_ALL=C s="$1" keep_slash="$2" out="" c h i
    for (( i = 0; i < ${#s}; i++ )); do
        c="${s:i:1}"
        case "$c" in
            [A-Za-z0-9._~-]) out+="$c" ;;
            /) if [ "$keep_slash" = "1" ]; then out+="/"; else out+="%2F"; fi ;;
            *) printf -v h '%%%02X' "'${c}"; out+="$h" ;;
        esac
    done
    printf '%s' "$out"
}

# 绝对路径（不解析符号链接，cd+pwd -P 通吃 Linux/macOS/BSD）
abs_file() {
    local f="$1" d b
    d=$(cd -- "$(dirname "$f")" 2>/dev/null && pwd -P) || return 1
    b=$(basename "$f")
    printf '%s/%s' "${d%/}" "$b"
}

find_browser() {
    if [ -n "${SCRATCHVERILOG_BROWSER:-}" ]; then
        if [ -x "$SCRATCHVERILOG_BROWSER" ]; then
            printf '%s' "$SCRATCHVERILOG_BROWSER"
            return 0
        fi
        echo "SCRATCHVERILOG_BROWSER 指向的不是可执行文件：$SCRATCHVERILOG_BROWSER" >&2
        return 2
    fi
    local c app
    # firefox 排在最后：有 Chromium 系就优先用它（firefox 读不了命令行文件）
    for c in msedge microsoft-edge google-chrome google-chrome-stable chromium chromium-browser brave-browser firefox; do
        if command -v "$c" >/dev/null 2>&1; then
            command -v "$c"
            return 0
        fi
    done
    for app in "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
               "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
               "/Applications/Chromium.app/Contents/MacOS/Chromium" \
               "/Applications/Firefox.app/Contents/MacOS/firefox"; do
        if [ -x "$app" ]; then
            printf '%s' "$app"
            return 0
        fi
    done
    return 1
}

FILE=""
DRY_RUN=0
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run|-n) DRY_RUN=1 ;;
        -h|--help) usage; exit 0 ;;
        --file|-f)
            if [ $# -lt 2 ]; then
                echo "--file 后面要跟一个文件路径（用 --help 看用法）" >&2
                exit 1
            fi
            FILE="$2"
            shift
            ;;
        -*) echo "未知参数：$1（用 --help 看用法）" >&2; exit 1 ;;
        *) FILE="$1" ;;
    esac
    shift
done

FILE_URI=""
DISPLAY_NAME=""
if [ -n "$FILE" ]; then
    if [ ! -e "$FILE" ]; then
        echo "文件不存在：$FILE" >&2
        exit 1
    fi
    if [ -d "$FILE" ]; then
        echo "这是文件夹，请指定具体文件：$FILE" >&2
        exit 1
    fi
    ABS=$(abs_file "$FILE") || { echo "无法解析路径：$FILE" >&2; exit 1; }
    FILE_URI="file://$(uri_escape "$ABS" 1)"
    DISPLAY_NAME=$(basename "$ABS")
fi

PAGE_URI="file://$(uri_escape "$HTML_PATH" 1)"
URL="$PAGE_URI"
if [ -n "$FILE_URI" ]; then
    URL="$PAGE_URI?file=$(uri_escape "$FILE_URI" 0)"
fi

BROWSER=$(find_browser) || {
    # 返回 2 是 SCRATCHVERILOG_BROWSER 配置错，具体原因上面已经打过了
    if [ $? -ne 2 ]; then
        echo "没找到 Edge / Chrome / Chromium / Firefox。" >&2
        echo "装好其中一个，或用 SCRATCHVERILOG_BROWSER=/path/to/chrome 指定。" >&2
    fi
    exit 1
}

# 按文件名判断：firefox 可能在 /usr/bin、/snap/bin、/opt/firefox 下
IS_FIREFOX=0
case "$(basename "$BROWSER")" in
    firefox*) IS_FIREFOX=1 ;;
esac

if [ "$DRY_RUN" = "1" ]; then
    echo "browser : $BROWSER"
    if [ "$IS_FIREFOX" = "1" ]; then
        echo "args    : \"$PAGE_URI\""
        echo "profile : （Firefox 复用默认 profile）"
        if [ -n "$FILE" ]; then
            echo "note    : Firefox 不能命令行读文件，将只打开编辑器"
        fi
    else
        echo "args    : --app=\"$URL\" --allow-file-access-from-files --user-data-dir=\"$PROFILE_DIR\""
        echo "profile : $PROFILE_DIR"
    fi
    exit 0
fi

if [ -n "$DISPLAY_NAME" ] && [ "$IS_FIREFOX" != "1" ]; then
    echo "打开 $DISPLAY_NAME ..."
else
    echo "打开 ScratchVerilog ..."
fi

# Firefox：没有 --app，也不能 fetch 本地文件，只能把页面交给默认窗口。
# 这里故意不传 ?file=：传了页面会去 fetch 然后必然失败，白白多一条报错。
if [ "$IS_FIREFOX" = "1" ]; then
    if [ -n "$FILE" ]; then
        echo "提示：Firefox 不能在命令行读入文件，已只打开编辑器。" >&2
        echo "      请在编辑器里点「打开文件」，或把文件直接拖到页面上。" >&2
    fi
    "$BROWSER" "$PAGE_URI" >/dev/null 2>&1 &
    exit 0
fi

mkdir -p "$PROFILE_DIR" || {
    echo "无法创建 profile 目录：$PROFILE_DIR" >&2
    exit 1
}

"$BROWSER" --app="$URL" --allow-file-access-from-files --user-data-dir="$PROFILE_DIR" >/dev/null 2>&1 &
exit 0
