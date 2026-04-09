#!/bin/bash

# Android SDK 一键安装脚本

echo "📱 Android SDK 安装脚本"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否已安装 Android SDK
check_android_sdk() {
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        echo -e "${GREEN}✅ 检测到 Android SDK: $ANDROID_HOME${NC}"
        return 0
    fi
    
    # 检查常见位置
    if [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        echo -e "${GREEN}✅ 检测到 Android SDK: $ANDROID_HOME${NC}"
        return 0
    fi
    
    return 1
}

# 检查必要的工具
check_tools() {
    local missing_tools=()
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if ! command -v unzip &> /dev/null; then
        missing_tools+=("unzip")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}❌ 缺少必要的工具: ${missing_tools[*]}${NC}"
        echo "请先安装这些工具"
        return 1
    fi
    
    return 0
}

# 安装命令行工具
install_command_line_tools() {
    echo ""
    echo "📥 开始下载 Android SDK 命令行工具..."
    
    # SDK 目录
    SDK_DIR="$HOME/Library/Android/sdk"
    CMDLINE_TOOLS_DIR="$SDK_DIR/cmdline-tools"
    
    # 创建目录
    mkdir -p "$CMDLINE_TOOLS_DIR"
    
    # 下载 URL（使用最新的命令行工具）
    # 注意：这个 URL 可能需要更新，建议从官方页面获取最新链接
    DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"
    TEMP_ZIP="/tmp/android-commandlinetools.zip"
    
    echo "正在从 Google 下载命令行工具..."
    if ! curl -L -o "$TEMP_ZIP" "$DOWNLOAD_URL"; then
        echo -e "${RED}❌ 下载失败${NC}"
        echo ""
        echo "请手动下载："
        echo "1. 访问: https://developer.android.com/studio#command-tools"
        echo "2. 下载 macOS 版本的 commandlinetools"
        echo "3. 将文件保存到: $TEMP_ZIP"
        echo ""
        read -p "如果已手动下载，请输入文件路径（直接回车跳过）: " manual_path
        
        if [ -n "$manual_path" ] && [ -f "$manual_path" ]; then
            TEMP_ZIP="$manual_path"
        else
            return 1
        fi
    fi
    
    echo "📦 解压命令行工具..."
    cd "$CMDLINE_TOOLS_DIR"
    
    if ! unzip -q "$TEMP_ZIP"; then
        echo -e "${RED}❌ 解压失败${NC}"
        return 1
    fi
    
    # 重命名目录
    if [ -d "cmdline-tools" ]; then
        mv cmdline-tools latest
    else
        echo -e "${YELLOW}⚠️  解压后的目录结构可能不同，请手动检查${NC}"
    fi
    
    # 清理临时文件
    rm -f "$TEMP_ZIP"
    
    echo -e "${GREEN}✅ 命令行工具安装完成${NC}"
    return 0
}

# 配置环境变量
setup_environment() {
    echo ""
    echo "⚙️  配置环境变量..."
    
    SDK_DIR="$HOME/Library/Android/sdk"
    ZSHRC="$HOME/.zshrc"
    
    # 检查是否已存在配置
    if grep -q "ANDROID_HOME.*Android/sdk" "$ZSHRC" 2>/dev/null; then
        echo -e "${YELLOW}ℹ️  环境变量配置已存在${NC}"
    else
        echo "" >> "$ZSHRC"
        echo "# Android SDK" >> "$ZSHRC"
        echo "export ANDROID_HOME=\$HOME/Library/Android/sdk" >> "$ZSHRC"
        echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> "$ZSHRC"
        echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> "$ZSHRC"
        echo -e "${GREEN}✅ 环境变量已添加到 ~/.zshrc${NC}"
    fi
    
    # 设置当前会话的环境变量
    export ANDROID_HOME="$SDK_DIR"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
}

# 安装 SDK 组件
install_sdk_components() {
    echo ""
    echo "📦 安装必要的 SDK 组件..."
    
    SDK_DIR="$HOME/Library/Android/sdk"
    export ANDROID_HOME="$SDK_DIR"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    
    # 检查 sdkmanager 是否可用
    if ! command -v sdkmanager &> /dev/null; then
        echo -e "${RED}❌ sdkmanager 不可用，请检查命令行工具安装${NC}"
        return 1
    fi
    
    echo "接受许可证..."
    yes | sdkmanager --licenses > /dev/null 2>&1
    
    echo "安装 platform-tools..."
    sdkmanager "platform-tools" || {
        echo -e "${YELLOW}⚠️  platform-tools 安装失败，可能需要网络连接${NC}"
    }
    
    echo "安装 Android Platform 34..."
    sdkmanager "platforms;android-34" || {
        echo -e "${YELLOW}⚠️  Android Platform 34 安装失败，可能需要网络连接${NC}"
    }
    
    echo "安装 Build Tools 34.0.0..."
    sdkmanager "build-tools;34.0.0" || {
        echo -e "${YELLOW}⚠️  Build Tools 安装失败，可能需要网络连接${NC}"
    }
    
    echo -e "${GREEN}✅ SDK 组件安装完成${NC}"
}

# 创建 local.properties 文件
create_local_properties() {
    echo ""
    echo "📝 创建 local.properties 文件..."
    
    SDK_DIR="$HOME/Library/Android/sdk"
    LOCAL_PROPERTIES="android/local.properties"
    
    if [ ! -f "$LOCAL_PROPERTIES" ]; then
        echo "sdk.dir=$SDK_DIR" > "$LOCAL_PROPERTIES"
        echo -e "${GREEN}✅ 已创建 $LOCAL_PROPERTIES${NC}"
    else
        # 更新现有文件
        if ! grep -q "sdk.dir=" "$LOCAL_PROPERTIES"; then
            echo "sdk.dir=$SDK_DIR" >> "$LOCAL_PROPERTIES"
        else
            sed -i '' "s|sdk.dir=.*|sdk.dir=$SDK_DIR|" "$LOCAL_PROPERTIES"
        fi
        echo -e "${GREEN}✅ 已更新 $LOCAL_PROPERTIES${NC}"
    fi
}

# 验证安装
verify_installation() {
    echo ""
    echo "🔍 验证安装..."
    
    SDK_DIR="$HOME/Library/Android/sdk"
    export ANDROID_HOME="$SDK_DIR"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
    
    if [ -d "$ANDROID_HOME" ]; then
        echo -e "${GREEN}✅ ANDROID_HOME: $ANDROID_HOME${NC}"
    else
        echo -e "${RED}❌ ANDROID_HOME 目录不存在${NC}"
        return 1
    fi
    
    if [ -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
        echo -e "${GREEN}✅ 命令行工具已安装${NC}"
    else
        echo -e "${RED}❌ 命令行工具未找到${NC}"
        return 1
    fi
    
    if command -v sdkmanager &> /dev/null; then
        echo -e "${GREEN}✅ sdkmanager 可用${NC}"
    else
        echo -e "${YELLOW}⚠️  sdkmanager 不可用，请运行: source ~/.zshrc${NC}"
    fi
    
    return 0
}

# 主函数
main() {
    # 检查是否已安装
    if check_android_sdk; then
        echo ""
        echo -e "${YELLOW}ℹ️  Android SDK 似乎已安装${NC}"
        read -p "是否继续安装/更新组件？(y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "已取消"
            exit 0
        fi
    fi
    
    # 检查必要工具
    if ! check_tools; then
        exit 1
    fi
    
    # 安装命令行工具
    if ! install_command_line_tools; then
        echo -e "${RED}❌ 安装失败${NC}"
        exit 1
    fi
    
    # 配置环境变量
    setup_environment
    
    # 安装 SDK 组件
    install_sdk_components
    
    # 创建 local.properties
    create_local_properties
    
    # 验证安装
    verify_installation
    
    echo ""
    echo -e "${GREEN}🎉 Android SDK 安装完成！${NC}"
    echo ""
    echo "下一步："
    echo "1. 运行: source ~/.zshrc"
    echo "2. 或重新打开终端"
    echo "3. 然后运行: ./build-app.sh"
    echo ""
}

# 运行主函数
main

