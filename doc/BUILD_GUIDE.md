# Android 应用构建指南

## ✅ 已完成的工作

1. ✅ 项目已配置 Capacitor
2. ✅ Android 平台已添加
3. ✅ dist 目录已同步到 Android 项目
4. ✅ 构建配置已验证

## 📱 构建 Android APK

### 方法一：使用构建脚本（推荐）

```bash
./build-app.sh
```

### 方法二：手动构建

#### 1. 同步文件（如果修改了 dist 目录）
```bash
npx cap sync
```

#### 2. 构建 APK

**构建 Debug 版本（用于测试）：**
```bash
cd android
./gradlew assembleDebug
```

**构建 Release 版本（用于发布）：**
```bash
cd android
./gradlew assembleRelease
```

#### 3. 找到生成的 APK

- **Debug APK**: `android/app/build/outputs/apk/debug/app-debug.apk`
- **Release APK**: `android/app/build/outputs/apk/release/app-release.apk`

### 方法三：使用 Android Studio

1. 打开 Android Studio
2. 选择 `File` -> `Open`，选择 `android` 目录
3. 等待 Gradle 同步完成
4. 点击 `Build` -> `Build Bundle(s) / APK(s)` -> `Build APK(s)`
5. 构建完成后，点击通知中的 `locate` 查看 APK 文件

## 🔧 前置要求

### 1. 安装 Java Development Kit (JDK)

Android 构建需要 JDK 17 或更高版本。

**检查是否已安装：**
```bash
java -version
```

**如果未安装，可以：**
- macOS: `brew install openjdk@17`
- 或从 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) 下载

### 2. 安装 Android SDK（必需）

**方式一：安装 Android Studio（推荐）**
- 下载并安装 [Android Studio](https://developer.android.com/studio)
- 安装 Android SDK（Android Studio 会自动处理）
- SDK 通常位于：`~/Library/Android/sdk`

**方式二：仅安装命令行工具**
- 查看 `INSTALL_ANDROID_SDK.md` 获取详细说明

**注意**：Android SDK 是构建 APK 的必需组件，必须安装后才能构建。

### 3. 配置环境变量（如果需要）

如果使用命令行构建，可能需要设置 `ANDROID_HOME`：

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

## 📦 安装 APK 到设备

### 使用 ADB（Android Debug Bridge）

1. 启用设备的开发者选项和 USB 调试
2. 连接设备到电脑
3. 运行：
```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

### 直接传输

将 APK 文件传输到 Android 设备，然后在设备上点击安装。

## 🔐 签名 Release APK（用于发布）

Release 版本的 APK 需要签名才能安装。首次发布需要创建签名密钥：

```bash
cd android/app
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

然后在 `android/app/build.gradle` 中配置签名信息。

## 📝 应用信息

- **应用 ID**: `com.h5app.app`
- **应用名称**: `怂团`
- **最低 Android 版本**: Android 5.1 (API 22)
- **目标 Android 版本**: Android 14 (API 34)

## 🐛 常见问题

### 问题：找不到 Java
**解决方案**: 安装 JDK 17 或更高版本

### 问题：Gradle 构建失败
**解决方案**: 
- 检查网络连接（需要下载依赖）
- 运行 `cd android && ./gradlew clean` 清理构建缓存
- 检查 `android/gradle/wrapper/gradle-wrapper.properties` 中的 Gradle 版本

### 问题：同步失败
**解决方案**: 
- 确保 `dist` 目录存在且包含 `index.html`
- 运行 `npx cap sync` 重新同步

### 问题：SDK location not found
**解决方案**: 
- 安装 Android SDK（推荐使用 Android Studio）
- 设置 `ANDROID_HOME` 环境变量：`export ANDROID_HOME=$HOME/Library/Android/sdk`
- 或创建 `android/local.properties` 文件，添加：`sdk.dir=/Users/你的用户名/Library/Android/sdk`
- 详细说明请查看 `INSTALL_ANDROID_SDK.md`

## 🎯 下一步

1. 构建 APK 文件
2. 在 Android 设备上测试应用
3. 根据需要调整配置（应用图标、启动画面等）
4. 准备发布时配置签名

