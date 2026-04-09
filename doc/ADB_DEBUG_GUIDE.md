# ADB 调试记录

本文档记录本项目在 Android 真机上的常用调试命令与排查步骤。

## 1. 准备工作

- 手机开启开发者选项和 `USB 调试`
- 电脑已安装 `adb`
- 使用数据线连接手机并授权调试

## 2. 基础连接检查

```bash
adb kill-server
adb start-server
adb devices -l
```

预期：

- 设备状态应为 `device`
- 若是 `unauthorized`，需要在手机上确认 USB 调试授权

## 3. 安装与启动 APK

项目包名：`com.h5app.app`

```bash
# 卸载旧包（可选）
adb uninstall com.h5app.app

# 安装 debug 包
adb install -r "android/app/build/outputs/apk/debug/app-debug.apk"

# 启动应用
adb shell monkey -p com.h5app.app -c android.intent.category.LAUNCHER 1

# 查看进程是否在运行
adb shell pidof com.h5app.app
```

## 4. 实时查看日志（推荐）

### 4.1 查看全部日志

```bash
adb logcat
```

### 4.2 查看项目常用关键字日志

```bash
adb logcat | rg -i "capacitor|chromium|webview|ssl|net::|weixin|hortor|fetch|xhr|failed|error"
```

### 4.3 只看当前应用日志（按 PID 过滤）

```bash
PID=$(adb shell pidof com.h5app.app)
adb logcat --pid="$PID"
```

## 5. Chrome DevTools 调试 WebView 请求

1. 保持手机连接电脑并打开 APP
2. 电脑 Chrome 打开：`chrome://inspect/#devices`
3. 勾选 `Discover USB devices`
4. 点击对应 WebView 的 `inspect`
5. 在 `Network` 面板查看请求

说明：

- 本项目已在 `MainActivity` 中开启 WebView 调试
- 若看不到应用，优先确认安装的是 debug 包而非 release 包

## 6. 导出日志文件（便于问题复盘）

```bash
# 导出完整日志到文件
adb logcat -d > adb-log.txt

# 清空历史日志再复现问题
adb logcat -c
adb logcat > adb-live.log
```

建议流程：

1. `adb logcat -c`
2. 重新打开 APP 并复现问题
3. `Ctrl + C` 停止日志
4. 保存 `adb-live.log` 用于分析

## 7. 本项目已做的网络兼容配置

为兼容 **HTTP 代理域名**（由本地 `PROXY_BASE_URL` 配置决定），已做：

- `MainActivity` 允许混合内容
- `AndroidManifest.xml` 启用明文流量
- `network_security_config.xml` 放行代理域名（按需配置）

如仍失败，优先检查：

- 请求是否被改写到 `/api/weixin`、`/api/weixin-long`、`/api/hortor`
- 代理服务器是否返回 404/5xx
- 是否是接口本身参数错误

## 8. 常见问题速查

- `device unauthorized`
  - 重新插线，在手机端确认授权
- `no devices/emulators found`
  - 检查 USB 连接和驱动，执行 `adb kill-server && adb start-server`
- `INSTALL_FAILED_VERSION_DOWNGRADE`
  - 先 `adb uninstall com.h5app.app` 再安装
- `mixed-content`
  - 本项目已处理，若再次出现请确认安装的是最新 debug 包

