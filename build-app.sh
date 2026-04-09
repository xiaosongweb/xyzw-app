#!/bin/bash

# 构建 Android APK 脚本

echo "🚀 开始构建 Android 应用..."

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANDROID_DIR="$ROOT_DIR/android"

load_env_file() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    echo "📄 加载环境配置: $env_file"
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
  fi
}

# ---- 构建期 env 配置（默认值不变）----
# 优先级：命令行环境变量 > .env > 默认值
load_env_file "$ROOT_DIR/.env"

APP_NAME="${APP_NAME:-怂团}"
APP_ID="${APP_ID:-com.h5app.app}"
WEB_DIR="${WEB_DIR:-dist}"
PROXY_BASE_URL="${PROXY_BASE_URL:-}"

export APP_NAME
export APP_ID
export WEB_DIR
export PROXY_BASE_URL

echo "🧩 构建配置: APP_NAME=$APP_NAME | APP_ID=$APP_ID | WEB_DIR=$WEB_DIR"
echo ""

# 将 APP_NAME/APP_ID 写入 Android 原生资源（桌面显示名来自这里）
# 构建前备份，构建后自动还原，避免污染工作区
ANDROID_STRINGS_XML="$ANDROID_DIR/app/src/main/res/values/strings.xml"
if [ -f "$ANDROID_STRINGS_XML" ]; then
    STRINGS_XML_BACKUP="$(mktemp -t strings.xml.XXXXXX)"
    cp "$ANDROID_STRINGS_XML" "$STRINGS_XML_BACKUP"

    restore_strings_xml() {
      if [ -n "$STRINGS_XML_BACKUP" ] && [ -f "$STRINGS_XML_BACKUP" ]; then
        cp "$STRINGS_XML_BACKUP" "$ANDROID_STRINGS_XML"
        rm -f "$STRINGS_XML_BACKUP"
      fi
    }

    # 无论构建成功/失败，都还原原文件
    trap restore_strings_xml EXIT INT TERM

    echo "📝 临时更新 Android strings.xml（构建结束自动还原）..."
    python3 - "$ANDROID_STRINGS_XML" "$APP_NAME" "$APP_ID" <<'PY'
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

path = Path(sys.argv[1])
new_name = sys.argv[2]
app_id = sys.argv[3]

tree = ET.parse(path)
root = tree.getroot()

def upsert(name: str, value: str):
    el = root.find(f".//string[@name='{name}']")
    if el is None:
        el = ET.SubElement(root, "string", {"name": name})
    el.text = value

upsert("app_name", new_name)
upsert("title_activity_main", new_name)
upsert("package_name", app_id)
upsert("custom_url_scheme", app_id)

tree.write(path, encoding="utf-8", xml_declaration=True)
PY
else
    echo "⚠️ 未找到 $ANDROID_STRINGS_XML，跳过应用名称更新"
fi

# 检查 Java
echo "☕ 检查 Java 环境..."
if ! command -v java &> /dev/null; then
    # 尝试设置 Java 路径（Homebrew 安装的 OpenJDK）
    if [ -f /opt/homebrew/opt/openjdk@17/bin/java ]; then
        export JAVA_HOME=/opt/homebrew/opt/openjdk@17
        export PATH=$JAVA_HOME/bin:$PATH
    elif [ -f /usr/local/opt/openjdk@17/bin/java ]; then
        export JAVA_HOME=/usr/local/opt/openjdk@17
        export PATH=$JAVA_HOME/bin:$PATH
    else
        echo "❌ 错误：未找到 Java"
        echo "请先安装 Java 17 或更高版本："
        echo "  brew install openjdk@17"
        echo "或查看 INSTALL_JAVA.md 获取详细说明"
        exit 1
    fi
fi

java -version
echo "✅ Java 环境检查通过"
echo ""

# 检查 Android SDK
echo "📱 检查 Android SDK..."
if [ -z "$ANDROID_HOME" ]; then
    # 尝试常见位置
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
    elif [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    fi
fi

if [ -z "$ANDROID_HOME" ] || [ ! -d "$ANDROID_HOME" ]; then
    echo "❌ 错误：未找到 Android SDK"
    echo ""
    echo "请安装 Android SDK："
    echo ""
    echo "方式一：使用一键安装脚本（推荐）"
    echo "  ./install-android-sdk.sh"
    echo ""
    echo "方式二：安装 Android Studio"
    echo "  1. 下载：https://developer.android.com/studio"
    echo "  2. 安装 Android Studio，它会自动安装 Android SDK"
    echo "  3. SDK 通常位于：~/Library/Android/sdk"
    echo ""
    echo "方式三：手动安装命令行工具"
    echo "  查看 INSTALL_ANDROID_SDK.md 获取详细说明"
    echo ""
    exit 1
fi

echo "✅ Android SDK 位置: $ANDROID_HOME"

# 创建 local.properties 文件（如果不存在）
if [ ! -f "$ANDROID_DIR/local.properties" ]; then
    echo "📝 创建 local.properties 文件..."
    echo "sdk.dir=$ANDROID_HOME" > "$ANDROID_DIR/local.properties"
fi

echo ""

WEB_DIR_CLEAN="${WEB_DIR%/}"
INDEX_HTML_PATH="$ROOT_DIR/${WEB_DIR_CLEAN}/index.html"

if [ ! -f "$INDEX_HTML_PATH" ]; then
    echo "❌ 错误：未找到 $INDEX_HTML_PATH"
    echo "请先确保 ${WEB_DIR_CLEAN} 目录已生成"
    exit 1
fi

# 0. 注入 WebView 代理脚本（可选）
if [ -n "${PROXY_BASE_URL:-}" ]; then
    echo "🌐 配置 WebView 代理... (PROXY_BASE_URL=$PROXY_BASE_URL)"
    python3 - "$INDEX_HTML_PATH" "$PROXY_BASE_URL" <<'PY'
import sys
from pathlib import Path

html_path = Path(sys.argv[1])
proxy_base = sys.argv[2].rstrip("/")

start_marker = "<!-- AUTO_PROXY_SCRIPT_START -->"
end_marker = "<!-- AUTO_PROXY_SCRIPT_END -->"

script_block = f"""{start_marker}
    <script>
      (function () {{
        var API_PROXY_BASE =
          window.__API_PROXY_BASE ||
          localStorage.getItem("API_PROXY_BASE") ||
          "{proxy_base}";

        function normalizeBase(base) {{
          return String(base || "").replace(/\\/+$/, "");
        }}

        var base = normalizeBase(API_PROXY_BASE);
        if (!base) return;

        var PROXY_PATH_PREFIXES = ["/api/weixin-long", "/api/weixin", "/api/hortor"];

        function mapPath(pathname) {{
          for (var i = 0; i < PROXY_PATH_PREFIXES.length; i++) {{
            if (pathname.indexOf(PROXY_PATH_PREFIXES[i]) === 0) {{
              return pathname;
            }}
          }}
          return null;
        }}

        function rewriteUrl(input) {{
          try {{
            var raw = typeof input === "string" ? input : input && input.url;
            if (!raw) return input;

            var url = new URL(raw, window.location.href);
            var path = mapPath(url.pathname);
            if (!path) return input;

            return base + path + (url.search || "");
          }} catch (e) {{
            return input;
          }}
        }}

        var rawFetch = window.fetch;
        if (typeof rawFetch === "function") {{
          window.fetch = function (input, init) {{
            var rewritten = rewriteUrl(input);
            if (typeof input === "string") {{
              return rawFetch.call(this, rewritten, init);
            }}
            if (input instanceof Request && typeof rewritten === "string" && rewritten !== input.url) {{
              return rawFetch.call(this, new Request(rewritten, input), init);
            }}
            return rawFetch.call(this, input, init);
          }};
        }}

        var rawOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function (method, url) {{
          var rewritten = rewriteUrl(url);
          return rawOpen.apply(this, [method, rewritten].concat([].slice.call(arguments, 2)));
        }};
      }})();
    </script>
{end_marker}"""

content = html_path.read_text(encoding="utf-8")

if start_marker in content and end_marker in content:
    start = content.index(start_marker)
    end = content.index(end_marker) + len(end_marker)
    new_content = content[:start] + script_block + content[end:]
else:
    anchor = '<script type="module" crossorigin src="/assets/'
    idx = content.find(anchor)
    if idx == -1:
        raise SystemExit("未找到注入位置：module script 标签")
    new_content = content[:idx] + script_block + "\n    " + content[idx:]

html_path.write_text(new_content, encoding="utf-8")
PY

    if [ $? -ne 0 ]; then
        echo "❌ 错误：代理脚本注入失败"
        exit 1
    fi

    echo "✅ 代理配置完成"
    echo ""
else
    echo "⏭️  未设置 PROXY_BASE_URL，跳过代理脚本注入"
    echo ""
fi

# 1. 同步文件
echo "📦 同步 ${WEB_DIR_CLEAN} 文件到 Android 项目..."
npx cap sync

# 2. 构建 APK
echo "🔨 构建 Android APK..."
cd "$ANDROID_DIR"

# 构建 Debug APK
echo "构建 Debug 版本..."
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Debug APK 构建成功！"
    echo "文件位置: android/app/build/outputs/apk/debug/app-debug.apk"
else
    echo ""
    echo "❌ Debug APK 构建失败"
    exit 1
fi

# 构建 Release APK（需要签名配置）
# echo ""
# echo "构建 Release 版本..."
# ./gradlew assembleRelease

# if [ $? -eq 0 ]; then
#     echo ""
#     echo "✅ Release APK 构建成功！"
#     echo "文件位置: android/app/build/outputs/apk/release/app-release.apk"
#     echo ""
#     echo "💡 提示：Release 版本需要签名才能安装到设备上"
# else
#     echo ""
#     echo "⚠️  Release APK 构建失败（可能需要签名配置）"
# fi

# echo ""
echo "✅ 构建完成！"

