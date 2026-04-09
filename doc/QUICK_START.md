# 🚀 快速开始 - 构建 APK

## ⚠️ 当前状态

构建 APK 需要安装 **Java** 和 **Android SDK**。

## 📋 构建 APK 的步骤

### 第一步：安装 Java（必需）

**选项 A：使用自动安装脚本（推荐）**
```bash
./install-java.sh
```

**选项 B：手动安装**
查看 `INSTALL_JAVA.md` 获取详细说明

**验证 Java 安装：**
```bash
java -version
```

应该看到类似：
```
openjdk version "17.0.x" ...
```

### 第二步：安装 Android SDK（必需）

**选项 A：使用一键安装脚本（推荐）**
```bash
./install-android-sdk.sh
```

**选项 B：安装 Android Studio**
1. 下载安装 [Android Studio](https://developer.android.com/studio)
2. 打开 Android Studio，它会自动安装 Android SDK
3. SDK 通常位于：`~/Library/Android/sdk`

**选项 C：手动安装**
查看 `INSTALL_ANDROID_SDK.md` 获取详细说明

**验证 Android SDK：**
```bash
echo $ANDROID_HOME
# 应该显示：/Users/你的用户名/Library/Android/sdk
```

### 第三步：构建 APK

**使用构建脚本：**
```bash
./build-app.sh
```

**或手动构建：**
```bash
cd android
./gradlew assembleDebug
```

### 第四步：找到 APK 文件

构建成功后，APK 位于：
- **Debug APK**: `android/app/build/outputs/apk/debug/app-debug.apk`
- **Release APK**: `android/app/build/outputs/apk/release/app-release.apk`

## 🎯 最快方式

如果您想最快构建 APK，推荐使用 **Android Studio**：

1. 下载安装 [Android Studio](https://developer.android.com/studio)
2. 打开 Android Studio
3. 选择 `File` → `Open`，选择项目中的 `android` 文件夹
4. 等待 Gradle 同步完成
5. 点击 `Build` → `Build Bundle(s) / APK(s)` → `Build APK(s)`
6. 构建完成后，点击通知中的 `locate` 查看 APK

## ✅ 已完成的工作

- ✅ dist 文件已同步到 Android 项目
- ✅ 构建配置已就绪
- ✅ 构建脚本已创建
- ✅ Java 安装脚本：`install-java.sh`
- ✅ Android SDK 安装脚本：`install-android-sdk.sh`
- ⏳ **等待安装 Java 和 Android SDK 后即可构建**

## 📚 更多信息

- 详细构建指南：`BUILD_GUIDE.md`
- Java 安装说明：`INSTALL_JAVA.md`
- Android SDK 安装说明：`INSTALL_ANDROID_SDK.md`

