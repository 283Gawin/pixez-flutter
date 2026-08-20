# PixEz Native iOS

这是 PixEz 的 iOS 16 原生迁移入口，目标是用 SwiftUI 取代 iOS 端 Flutter UI，并优先修复图片解码、动图播放、下载队列和页面生命周期带来的发热问题。

## 当前状态

- 原 Flutter 工程完整保留，作为功能对照和迁移参考。
- `native-ios/` 是新的 SwiftUI iOS 16 工程。
- 目前已建立原生 Tab、搜索、下载、设置页面，以及按显示尺寸解码的图片管线接口。
- Pixiv 登录和业务接口仍需逐项迁移，现阶段空状态页面是刻意保留的迁移占位，不代表功能已完成。

## GitHub 构建

Actions 中运行 `Build Native iOS`，构建完成后下载 `PixEzNative-unsigned-ipa` artifact。IPA 不包含开发者签名，适合在支持 TrollStore 的设备上进一步安装测试。