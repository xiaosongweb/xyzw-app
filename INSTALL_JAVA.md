# 安装 Java 构建 APK

## ⚠️ 当前状态

系统检测到**未安装 Java**，需要先安装 Java 才能构建 APK。

## 🚀 快速安装 Java（推荐方式）

### 方式一：使用 Homebrew（最简单）

1. **安装 Homebrew**（如果还没有）：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **安装 OpenJDK 17**：
```bash
brew install openjdk@17
```

3. **配置环境变量**（添加到 `~/.zshrc`）：
```bash
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

### 方式二：直接下载安装

1. 访问 [Oracle JDK 下载页面](https://www.oracle.com/java/technologies/downloads/#java17)
2. 下载 macOS 版本的 JDK 17
3. 安装下载的 .dmg 文件
4. 配置环境变量（同上）

### 方式三：使用 Android Studio（推荐用于 Android 开发）

1. 下载并安装 [Android Studio](https://developer.android.com/studio)
2. Android Studio 会自动安装 JDK
3. 在 Android Studio 中打开项目并构建

## ✅ 验证安装

安装完成后，运行以下命令验证：

```bash
java -version
```

应该看到类似输出：
```
openjdk version "17.0.x" ...
```

## 🔨 安装完成后构建 APK

Java 安装完成后，运行：

```bash
./build-app.sh
```

或者：

```bash
cd android
./gradlew assembleDebug
```

## 📝 注意事项

- Android 构建需要 **JDK 17 或更高版本**
- 确保 `JAVA_HOME` 环境变量已正确设置
- 如果使用 Android Studio，它会自动管理 JDK

