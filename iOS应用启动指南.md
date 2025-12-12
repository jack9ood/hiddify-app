# iOS 应用启动指南

本文档说明如何启动编译好的 iOS 应用（`build/ios/iphoneos/Runner.app`）。

---

## 📋 目录

1. [在 iOS 模拟器上运行](#在-ios-模拟器上运行)
2. [在真机上运行](#在真机上运行)
3. [使用 Flutter 命令运行](#使用-flutter-命令运行)
4. [使用 Xcode 运行](#使用-xcode-运行)
5. [常见问题](#常见问题)

---

## 在 iOS 模拟器上运行

### 方法一：使用 Flutter 命令（推荐）

```bash
# 1. 查看可用的模拟器
xcrun simctl list devices available

# 2. 启动模拟器（选择一个设备）
open -a Simulator

# 3. 使用 Flutter 运行应用
cd /Users/oulei/Desktop/src/hiddify-app
flutter run

# 或者指定设备
flutter run -d "iPhone 17 Pro"
```

### 方法二：直接安装到模拟器

```bash
# 1. 启动模拟器
open -a Simulator

# 2. 获取模拟器设备 ID
xcrun simctl list devices | grep Booted

# 3. 安装应用（需要先构建 Debug 版本）
flutter build ios --debug --simulator
xcrun simctl install booted build/ios/iphonesimulator/Runner.app

# 4. 启动应用
xcrun simctl launch booted app.hiddify.com
```

### 方法三：使用 xcodebuild 安装

```bash
# 1. 启动模拟器
open -a Simulator

# 2. 获取模拟器 UDID
xcrun simctl list devices available | grep "iPhone"

# 3. 安装应用
xcrun simctl install <DEVICE_UDID> build/ios/iphoneos/Runner.app
```

---

## 在真机上运行

⚠️ **注意**：在真机上运行需要代码签名。使用 `--no-codesign` 构建的应用无法直接安装到真机。

### 方法一：使用 Flutter 命令（需要代码签名）

```bash
# 1. 连接 iPhone 到 Mac
# 2. 信任设备（在 iPhone 上点击"信任"）

# 3. 查看连接的设备
flutter devices

# 4. 运行应用（会自动签名）
flutter run --release
```

### 方法二：使用 Xcode（推荐用于真机）

1. **打开 Xcode 项目**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **配置签名**
   - 在 Xcode 中选择项目 `Runner`
   - 选择 `Signing & Capabilities` 标签
   - 选择你的开发团队（Team）
   - Xcode 会自动生成配置文件

3. **选择设备**
   - 在 Xcode 顶部选择连接的 iPhone

4. **运行**
   - 点击运行按钮（▶️）或按 `Cmd + R`

### 方法三：使用 ios-deploy（需要代码签名）

```bash
# 1. 安装 ios-deploy
brew install ios-deploy

# 2. 安装应用到设备
ios-deploy --bundle build/ios/iphoneos/Runner.app

# 3. 启动应用
ios-deploy --bundle build/ios/iphoneos/Runner.app --justlaunch
```

---

## 使用 Flutter 命令运行

### 基本命令

```bash
# 查看可用设备
flutter devices

# 运行应用（自动选择设备）
flutter run

# 指定设备运行
flutter run -d <device-id>

# 运行 Release 版本
flutter run --release

# 运行 Debug 版本（默认）
flutter run --debug
```

### 查看设备列表

```bash
flutter devices

# 示例输出：
# 3 connected devices:
# 
# iPhone 17 Pro (mobile) • E100A640-1202-4E34-A461-A5C9698CBC65 • ios • com.apple.CoreSimulator.SimRuntime.iOS-26-1 (simulator)
# iPhone (mobile)        • 00008030-001234567890ABCD • ios • iOS 18.0 (device)
# macOS (desktop)        • macos  • darwin-arm64   • macOS 15.7.2 24G325 darwin-arm64
```

---

## 使用 Xcode 运行

### 步骤

1. **打开工作空间**
   ```bash
   cd /Users/oulei/Desktop/src/hiddify-app
   open ios/Runner.xcworkspace
   ```
   ⚠️ **重要**：必须打开 `.xcworkspace` 文件，不是 `.xcodeproj` 文件

2. **选择目标设备**
   - 在 Xcode 顶部工具栏选择设备（模拟器或真机）

3. **配置签名**（仅真机需要）
   - 选择项目 `Runner`
   - 选择 `Signing & Capabilities`
   - 选择你的开发团队

4. **运行**
   - 点击运行按钮（▶️）
   - 或按快捷键 `Cmd + R`

5. **停止**
   - 点击停止按钮（⏹️）
   - 或按快捷键 `Cmd + .`

---

## 常见问题

### Q1: 应用无法安装到模拟器

**错误**：
```
Unable to boot device
```

**解决**：
- 确保模拟器已启动：`open -a Simulator`
- 检查模拟器状态：`xcrun simctl list devices`
- 重启模拟器

### Q2: 代码签名错误（真机）

**错误**：
```
Code signing is required for product type 'Application' in SDK 'iOS'
```

**解决**：
- 在 Xcode 中配置签名
- 选择你的开发团队
- 或使用 `flutter run` 命令（会自动处理签名）

### Q3: 找不到设备

**错误**：
```
No devices found
```

**解决**：
- 检查设备连接：`flutter devices`
- 对于模拟器：`open -a Simulator`
- 对于真机：确保已信任设备

### Q4: Framework 未找到

**错误**：
```
ld: framework not found Libcore
```

**解决**：
- 确保已编译 Framework：`make build-ios-libs`
- 检查 Framework 位置：`ls ios/Frameworks/Libcore.xcframework`

### Q5: 应用崩溃

**可能原因**：
- Framework 版本不匹配
- 代码签名问题
- 缺少必要的权限配置

**解决**：
- 查看 Xcode 控制台日志
- 检查 `Info.plist` 中的权限配置
- 重新编译 Framework

---

## 快速参考

### 模拟器运行

```bash
# 最简单的方式
open -a Simulator
flutter run
```

### 真机运行

```bash
# 使用 Flutter（自动处理签名）
flutter run --release

# 或使用 Xcode
open ios/Runner.xcworkspace
# 然后在 Xcode 中点击运行
```

### 调试

```bash
# 查看日志
flutter logs

# 查看设备信息
flutter devices -v
```

---

## 相关文档

- [编译环境.md](./编译环境.md) - 完整的编译环境配置
- [私有库配置与编译指南.md](./私有库配置与编译指南.md) - iOS 编译说明

---

**最后更新**：2024-12-12
