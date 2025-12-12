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

⚠️ **重要**：在真机上运行需要代码签名。使用 `--no-codesign` 构建的应用无法直接安装到真机。

### 前置准备

1. **连接 iPhone 到 Mac**
   - 使用 USB 数据线连接
   - 在 iPhone 上点击"信任此电脑"
   - 输入 iPhone 密码确认

2. **检查设备连接**
   ```bash
   flutter devices
   # 应该能看到你的 iPhone 设备
   ```

3. **Apple 开发者账号**
   - 免费账号：可以安装到自己的设备（7天有效期）
   - 付费账号：可以安装到多台设备（1年有效期）

---

### 方法一：使用 Xcode（推荐，最简单）

这是最推荐的方法，Xcode 会自动处理代码签名。

#### 步骤

1. **打开 Xcode 工作空间**
   ```bash
   cd /Users/oulei/Desktop/src/hiddify-app
   open ios/Runner.xcworkspace
   ```
   ⚠️ **重要**：必须打开 `.xcworkspace` 文件，不是 `.xcodeproj` 文件

2. **配置代码签名**
   
   a. 在 Xcode 左侧项目导航器中，选择项目 `Runner`（最顶部的蓝色图标）
   
   b. 选择 `Runner` target（在 TARGETS 下）
   
   c. 点击 `Signing & Capabilities` 标签
   
   d. 勾选 `Automatically manage signing`
   
   e. 在 `Team` 下拉菜单中选择你的 Apple ID 或开发团队
   
   f. 如果第一次使用，Xcode 会提示：
      - 点击 `Add Account...` 添加 Apple ID
      - 登录后选择你的账号
   
   g. Xcode 会自动：
      - 生成 Provisioning Profile
      - 配置 Bundle Identifier
      - 设置代码签名证书

3. **选择目标设备**
   - 在 Xcode 顶部工具栏，点击设备选择器
   - 选择你连接的 iPhone

4. **构建并运行**
   - 点击运行按钮（▶️）
   - 或按快捷键 `Cmd + R`
   - Xcode 会自动：
     - 构建应用
     - 签名应用
     - 安装到设备
     - 启动应用

5. **在设备上信任开发者**
   - 首次安装后，在 iPhone 上：
   - 打开 `设置` → `通用` → `VPN与设备管理`（或 `设备管理`）
   - 找到你的开发者账号
   - 点击 `信任 [你的名字]`
   - 确认信任

6. **运行应用**
   - 现在可以在 iPhone 上打开应用了

---

### 方法二：使用 Flutter 命令（自动处理签名）

Flutter 可以自动处理代码签名，但需要先在 Xcode 中配置一次。

#### 步骤

1. **首次配置（只需一次）**
   ```bash
   # 打开 Xcode 配置签名（参考方法一）
   open ios/Runner.xcworkspace
   # 在 Xcode 中配置签名后关闭
   ```

2. **使用 Flutter 运行**
   ```bash
   # 查看连接的设备
   flutter devices
   
   # 运行应用（会自动签名和安装）
   flutter run --release
   
   # 或指定设备
   flutter run --release -d <device-id>
   ```

3. **构建并安装（不运行）**
   ```bash
   # 构建 Release 版本
   flutter build ios --release
   
   # 应用会构建在 build/ios/iphoneos/Runner.app
   # 然后可以使用 Xcode 或 ios-deploy 安装
   ```

---

### 方法三：使用 ios-deploy（命令行安装）

适合已经构建好的应用，需要手动签名。

#### 安装 ios-deploy

```bash
brew install ios-deploy
```

#### 步骤

1. **确保应用已签名**
   ```bash
   # 使用 Xcode 构建并签名（方法一）
   # 或使用 Flutter 构建（方法二）
   flutter build ios --release
   ```

2. **安装到设备**
   ```bash
   # 安装应用
   ios-deploy --bundle build/ios/iphoneos/Runner.app
   
   # 安装并启动
   ios-deploy --bundle build/ios/iphoneos/Runner.app --justlaunch
   
   # 查看设备信息
   ios-deploy --detect
   ```

---

### 方法四：使用 Xcode 命令行工具

#### 步骤

1. **构建应用（已签名）**
   ```bash
   # 在 Xcode 中先配置签名，然后：
   cd ios
   xcodebuild -workspace Runner.xcworkspace \
     -scheme Runner \
     -configuration Release \
     -destination 'generic/platform=iOS' \
     -archivePath build/Runner.xcarchive \
     archive
   ```

2. **导出 IPA**
   ```bash
   xcodebuild -exportArchive \
     -archivePath build/Runner.xcarchive \
     -exportPath build/export \
     -exportOptionsPlist exportOptions.plist
   ```

3. **安装 IPA**
   - 使用 Xcode → Window → Devices and Simulators
   - 或使用 Apple Configurator 2
   - 或使用第三方工具（如 3uTools）

---

### 方法五：无线调试（iOS 15+）

#### 设置无线连接

1. **首次通过 USB 连接**
   - 连接 iPhone 到 Mac
   - 在 Xcode 中：Window → Devices and Simulators
   - 选择你的设备
   - 勾选 `Connect via network`

2. **断开 USB，使用 Wi-Fi**
   - 确保 Mac 和 iPhone 在同一 Wi-Fi 网络
   - 在 Xcode 设备列表中选择无线连接的设备
   - 正常使用 `flutter run` 或 Xcode 运行

---

### 代码签名配置详解

#### 免费 Apple ID（个人开发）

- **限制**：
  - 应用有效期 7 天
  - 只能安装到自己的设备
  - 需要定期重新签名

- **配置**：
  - 在 Xcode 中选择 `Personal Team`
  - 使用你的 Apple ID 登录

#### 付费开发者账号（$99/年）

- **优势**：
  - 应用有效期 1 年
  - 可以安装到多台设备
  - 可以发布到 App Store
  - 可以使用 TestFlight

- **配置**：
  - 在 Xcode 中选择你的开发团队
  - 需要配置 Provisioning Profile

---

### 常见问题解决

#### Q1: "No devices found"

**原因**：设备未连接或未信任

**解决**：
```bash
# 检查设备连接
flutter devices

# 检查 USB 连接
# 在 iPhone 上：设置 → 通用 → 关于本机 → 检查是否显示 Mac 名称

# 重新信任设备
# 在 iPhone 上：设置 → 通用 → 传输或还原 iPhone → 还原 → 还原位置与隐私
```

#### Q2: "Code signing is required"

**原因**：未配置代码签名

**解决**：
- 在 Xcode 中配置签名（方法一）
- 确保选择了正确的 Team
- 检查 Bundle Identifier 是否唯一

#### Q3: "Provisioning profile doesn't match"

**原因**：Bundle ID 或设备不匹配

**解决**：
- 在 Xcode 中重新生成 Provisioning Profile
- 确保 Bundle ID 正确
- 确保设备已添加到开发者账号

#### Q4: "Untrusted Developer"

**原因**：首次安装后未信任开发者

**解决**：
- 在 iPhone 上：设置 → 通用 → VPN与设备管理
- 找到你的开发者账号
- 点击"信任"

#### Q5: 应用安装后立即崩溃

**可能原因**：
- Framework 未正确签名
- 缺少必要的权限配置
- 架构不匹配

**解决**：
```bash
# 重新构建 Framework
make build-ios-libs

# 重新构建应用
flutter clean
flutter build ios --release

# 检查 Info.plist 中的权限配置
```

#### Q6: "Device is not connected"

**原因**：USB 连接问题或驱动问题

**解决**：
- 更换 USB 数据线
- 尝试不同的 USB 端口
- 重启 iPhone 和 Mac
- 检查是否有 iTunes 或 Finder 占用连接

---

### 快速参考

#### 最简单的真机安装方法

```bash
# 1. 连接 iPhone 到 Mac
# 2. 在 iPhone 上点击"信任此电脑"

# 3. 打开 Xcode
open ios/Runner.xcworkspace

# 4. 在 Xcode 中：
#    - 选择项目 Runner
#    - 选择 Signing & Capabilities
#    - 选择你的 Team
#    - 选择你的 iPhone 作为目标设备
#    - 点击运行按钮（▶️）

# 5. 在 iPhone 上：
#    - 设置 → 通用 → VPN与设备管理
#    - 信任开发者
#    - 打开应用
```

#### 使用 Flutter 命令

```bash
# 首次需要先在 Xcode 中配置签名
open ios/Runner.xcworkspace
# 配置签名后关闭 Xcode

# 然后使用 Flutter 运行
flutter run --release
```

#### 检查设备连接

```bash
# 查看所有设备
flutter devices

# 查看详细信息
flutter devices -v

# 检查 iOS 设备
xcrun xctrace list devices
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
