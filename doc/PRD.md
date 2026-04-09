## 当前的dist是打包出来的静态包文件目录，我现在需要创建一个手机h5应用APP，把这个静态包的内容展示出来

### 已创建的配置

项目已配置 Capacitor，可以将 dist 目录打包为 iOS 和 Android 原生应用。

### 使用步骤

1. **安装依赖**
```bash
npm install
```

2. **添加平台（如果尚未添加）**

**注意**：项目已经配置了 `capacitor.config.ts` 文件，无需运行 `npx cap init`。如果您的项目还没有原生平台目录，请运行以下命令添加平台：
```bash
# 添加 Android 平台
npx cap add android

# 添加 iOS 平台（仅 macOS）
npx cap add ios
```

3. **同步文件**
```bash
npx cap sync
```
这个命令会将 dist 目录的内容复制到原生项目中。

4. **打开开发环境**
```bash
# Android
npx cap open android

# iOS
npx cap open ios
```

5. **构建和运行**
   - 在 Android Studio 或 Xcode 中构建并运行应用
   - 或者使用命令行工具进行构建

### ✅ 构建状态

**已完成：**
- ✅ dist 目录已同步到 Android 项目
- ✅ 所有配置文件已验证
- ✅ 已创建构建脚本 `build-app.sh`
- ✅ 已创建详细构建指南 `BUILD_GUIDE.md`

**快速构建 APK：**
```bash
# 方法一：使用构建脚本
./build-app.sh

# 方法二：手动构建
cd android
./gradlew assembleDebug
```

生成的 APK 位置：
- Debug: `android/app/build/outputs/apk/debug/app-debug.apk`
- Release: `android/app/build/outputs/apk/release/app-release.apk`

**详细说明请查看 `BUILD_GUIDE.md`**

### 注意事项

- **项目已配置**：项目已经包含 `capacitor.config.ts` 配置文件，**无需运行 `npx cap init`**。如果运行该命令会出现错误，因为 init 命令不支持 TypeScript 配置文件。
- `webDir` 配置为 `dist`，表示使用 dist 目录作为 Web 资源目录
- `appId`: `com.h5app.app` - 可以根据需要修改
- `appName`: `怂团` - 应用的显示名称
- 首次运行需要安装 Node.js 和对应的开发工具（Android Studio 或 Xcode）