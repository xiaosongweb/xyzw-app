# 安装 Android SDK 构建 APK

## ⚠️ 当前状态

系统检测到**未安装 Android SDK**，需要先安装 Android SDK 才能构建 APK。

## 🚀 快速安装 Android SDK

### 方式一：使用一键安装脚本（最简单，推荐）

项目提供了自动安装脚本，可以一键安装 Android SDK：

```bash
./install-android-sdk.sh
```

脚本会自动：
- ✅ 下载 Android SDK 命令行工具
- ✅ 配置环境变量
- ✅ 安装必要的 SDK 组件（platform-tools, Android Platform 34, Build Tools）
- ✅ 创建 local.properties 文件

**注意**：需要网络连接来下载工具和组件。

### 方式二：安装 Android Studio（推荐，最简单）

Android Studio 会自动安装和管理 Android SDK，是最简单的方式。

1. **下载 Android Studio**
   - 访问：https://developer.android.com/studio
   - 下载 macOS 版本

2. **安装 Android Studio**
   - 打开下载的 .dmg 文件
   - 将 Android Studio 拖到 Applications 文件夹
   - 首次启动时，选择 "Standard" 安装配置
   - Android Studio 会自动下载并安装 Android SDK

3. **找到 SDK 位置**
   - 打开 Android Studio
   - 选择 `Preferences` → `Appearance & Behavior` → `System Settings` → `Android SDK`
   - SDK 位置通常显示为：`/Users/你的用户名/Library/Android/sdk`

4. **配置环境变量**（添加到 `~/.zshrc`）：
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
source ~/.zshrc
```

5. **使用 Android Studio 构建**（可选）
   - 在 Android Studio 中打开项目的 `android` 目录
   - 点击 `Build` → `Build Bundle(s) / APK(s)` → `Build APK(s)`

### 方式二：仅安装命令行工具（轻量级）

如果不需要 Android Studio IDE，可以只安装命令行工具：

1. **下载命令行工具**
   - 访问：https://developer.android.com/studio#command-tools
   - 下载 macOS 版本的 "commandlinetools"

2. **解压并安装**
```bash
# 创建目录
mkdir -p ~/Library/Android/sdk/cmdline-tools
cd ~/Library/Android/sdk/cmdline-tools

# 解压下载的文件（假设文件名为 commandlinetools-mac-xxx.zip）
unzip ~/Downloads/commandlinetools-mac-*.zip

# 重命名目录
mv cmdline-tools latest

# 设置环境变量
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

3. **安装必要的 SDK 组件**
```bash
# 接受许可证
yes | sdkmanager --licenses

# 安装必要的组件
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 方式三：手动下载命令行工具（无需 Android Studio）

如果不想安装完整的 Android Studio，可以只下载命令行工具：

1. **下载命令行工具**
   - 访问：https://developer.android.com/studio#command-tools
   - 下载 macOS 版本的 "commandlinetools"（文件名类似 `commandlinetools-mac-11076708_latest.zip`）

2. **安装步骤**
```bash
# 创建 SDK 目录
mkdir -p ~/Library/Android/sdk

# 进入目录
cd ~/Library/Android/sdk

# 创建 cmdline-tools 目录
mkdir -p cmdline-tools

# 解压下载的文件（将 ~/Downloads/commandlinetools-mac-*.zip 替换为实际路径）
unzip ~/Downloads/commandlinetools-mac-*.zip -d cmdline-tools

# 重命名解压后的目录为 latest
cd cmdline-tools
mv cmdline-tools latest

# 设置环境变量（添加到 ~/.zshrc）
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc

# 接受许可证并安装必要的组件
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## ✅ 验证安装

安装完成后，运行以下命令验证：

```bash
# 检查 ANDROID_HOME
echo $ANDROID_HOME

# 检查 SDK 工具
adb version
```

## 🔧 配置项目

安装 Android SDK 后，有两种方式配置项目：

### 方式一：使用环境变量（推荐）

在 `~/.zshrc` 中添加：
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

然后运行：
```bash
source ~/.zshrc
```

### 方式二：创建 local.properties 文件

在项目根目录创建 `android/local.properties` 文件：

```properties
sdk.dir=/Users/你的用户名/Library/Android/sdk
```

**注意**：`local.properties` 文件通常应该添加到 `.gitignore` 中（因为它包含用户特定的路径）。

## 🔨 安装完成后构建 APK

Android SDK 安装完成后，运行：

```bash
./build-app.sh
```

或者：

```bash
cd android
./gradlew assembleDebug
```

## 📝 所需 SDK 组件

构建 APK 需要以下组件：

- **Platform Tools**（包含 adb）
- **Android Platform**（API 34，对应 Android 14）
- **Build Tools**（版本 34.0.0 或更高）

如果使用 Android Studio，这些组件会自动安装。

## 🐛 常见问题

### 问题：找不到 ANDROID_HOME
**解决方案**: 
- 检查 SDK 是否已安装
- 设置 `ANDROID_HOME` 环境变量
- 或创建 `android/local.properties` 文件

### 问题：SDK location not found
**解决方案**: 
- 确保 `ANDROID_HOME` 指向正确的 SDK 目录
- 检查 `android/local.properties` 文件中的 `sdk.dir` 路径是否正确

### 问题：缺少 SDK 组件
**解决方案**: 
- 打开 Android Studio → Preferences → Android SDK
- 安装缺失的组件（Platform、Build Tools 等）

## 🎯 推荐配置

对于本项目，推荐安装：

- **Android SDK Platform 34** (Android 14)
- **Android SDK Build-Tools 34.0.0**
- **Android SDK Platform-Tools**
- **Android SDK Command-line Tools**

这些组件可以通过 Android Studio 的 SDK Manager 安装。

