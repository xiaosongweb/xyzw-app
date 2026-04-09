#!/bin/bash

# Java 安装脚本（使用 Homebrew）

echo "🔍 检查 Homebrew..."

if ! command -v brew &> /dev/null; then
    echo "📦 正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 添加 Homebrew 到 PATH（适用于 Apple Silicon Mac）
    if [ -f /opt/homebrew/bin/brew ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew 已安装"
fi

echo ""
echo "☕ 正在安装 OpenJDK 17..."
brew install openjdk@17

echo ""
echo "⚙️  配置环境变量..."

# 检查是否已存在 JAVA_HOME 配置
if ! grep -q "JAVA_HOME.*openjdk@17" ~/.zshrc 2>/dev/null; then
    echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")' >> ~/.zshrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
    echo "✅ 环境变量已添加到 ~/.zshrc"
else
    echo "ℹ️  环境变量已存在"
fi

echo ""
echo "🔄 应用环境变量..."
export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || echo "/opt/homebrew/opt/openjdk@17")
export PATH=$JAVA_HOME/bin:$PATH

echo ""
echo "✅ 验证安装..."
java -version

echo ""
echo "🎉 Java 安装完成！"
echo ""
echo "💡 提示：如果 java -version 仍然不工作，请运行："
echo "   source ~/.zshrc"
echo "   或者重新打开终端"

