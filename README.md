## h5-app（Capacitor 封装 H5 静态包）

这是一个基于 **Capacitor v6** 的移动端应用壳工程，用于将项目根目录下的 `dist/` **静态资源包**打包成 **Android / iOS App** 并在 WebView 中展示。

- **应用名称**：怂团（见 `capacitor.config.ts`）
- **App ID**：`com.h5app.app`
- **Web 资源目录**：`dist/`

## 功能概述

- 将 `dist/` 的静态站点内容同步到原生工程（Android / iOS）
- 提供 Android 一键构建脚本，输出 Debug APK
- 构建时可选注入 WebView 请求代理脚本（用于接口转发/联调）

## 技术栈

- **Capacitor**：`@capacitor/core` / `@capacitor/cli` / `@capacitor/android` / `@capacitor/ios`（v6）
- **TypeScript**：用于 Capacitor 配置（`capacitor.config.ts`）

## 目录结构（关键部分）

- `dist/`：要被打包进 App 的静态资源目录（需包含 `index.html`）
- `android/`：Android 原生工程（Gradle）
- `ios/`：iOS 原生工程（Xcode，macOS 才能使用）
- `doc/`：构建与环境安装文档
  - `doc/BUILD_GUIDE.md`：Android 构建指南
  - `doc/INSTALL_JAVA.md`：安装 JDK 指南
  - `doc/INSTALL_ANDROID_SDK.md`：安装 Android SDK 指南

## 环境要求

- **Node.js**：用于运行 Capacitor CLI（`npx cap ...`）
- **Android 构建**：
  - **JDK 17+**
  - **Android SDK**（建议 Android 14 / API 34 相关组件）
- **iOS 构建（可选）**：
  - macOS + Xcode

## 快速开始

### 1) 安装依赖

```bash
npm install
```

### 2)（如需要）添加原生平台

> 项目已包含 `capacitor.config.ts`，**无需**运行 `npx cap init`。

```bash
# Android
npx cap add android

# iOS（仅 macOS）
npx cap add ios
```

### 3) 同步静态资源到原生工程

```bash
npx cap sync
```

### 4) 打开原生工程

```bash
npx cap open android
npx cap open ios
```

## Android 打包（APK）

### 方法一：一键脚本（推荐）

```bash
./build-app.sh
```

脚本会：

- 检查/尝试定位 **JDK 17**
- 检查/尝试定位 **Android SDK**，必要时生成 `android/local.properties`
- 校验 `dist/index.html` 存在
-（可选）向 `dist/index.html` 注入代理脚本（见下文）
- 执行 `npx cap sync` 同步资源
- 执行 `./gradlew assembleDebug` 构建 Debug APK

### 方法二：手动构建

```bash
npx cap sync
cd android
./gradlew assembleDebug
```

APK 输出位置：

- Debug：`android/app/build/outputs/apk/debug/app-debug.apk`
- Release：`android/app/build/outputs/apk/release/app-release.apk`

更多细节请看：`doc/BUILD_GUIDE.md`。

## WebView 代理配置（可选）

`build-app.sh` 支持通过环境变量 `PROXY_BASE_URL` 注入一段请求重写脚本到 `dist/index.html`，用于将特定接口路径转发到指定域名（脚本内含 `"/api/weixin-long"`, `"/api/weixin"`, `"/api/hortor"` 等前缀）。

示例：

```bash
PROXY_BASE_URL="http://xiaosongweb.cn" ./build-app.sh
```

## 常见问题

- **找不到 Java / 版本不对**：参考 `doc/INSTALL_JAVA.md`（Android 构建需要 JDK 17+）
- **找不到 Android SDK / ANDROID_HOME 未配置**：参考 `doc/INSTALL_ANDROID_SDK.md`
- **同步失败**：确认 `dist/` 下存在 `index.html`，再运行 `npx cap sync`

## 相关命令

```bash
# 同步资源到原生工程
npm run sync

# 仅复制 web 资源（不做完整 sync）
npm run copy

# 打开原生工程
npm run open:android
npm run open:ios
```

