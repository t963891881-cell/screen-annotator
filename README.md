# Screen Annotator

一个用于教学、录屏、演示时快速框选屏幕区域的 macOS 小工具。

## 使用

如果只想安装最新版，请到 GitHub Releases 下载 `.dmg` 安装包：

`https://github.com/t963891881-cell/screen-annotator/releases`

也可以从源码构建：

```bash
cd /Users/mac/Desktop/7654/screen-annotator
./scripts/build.sh
./scripts/run.sh
```

启动后应用会在后台常驻，不显示 Dock 图标。
菜单栏会显示 `✎` 图标，可以从这里打开设置页或退出应用。

## 快捷键

- `Option + 1`: 显示标注层，并切到矩形标注
- `Option + 2`: 显示标注层，并切到箭头标注
- `Option + 3`: 显示标注层，并切到步骤标注
- `Option + 4`: 显示标注层，并切到自由画笔
- `Option + 5`: 显示标注层，并把下一个步骤编号往后加 1
- 鼠标拖拽: 绘制矩形、箭头或自由画笔
- 鼠标点击: 放置步骤编号
- 按住 `Shift`: 临时显示标注层；松开 `Shift` 会清空并隐藏标注层
- `C`: 清空所有标注
- `Z`: 撤销上一个标注
- `R`: 切换标注颜色
- `Space`: 切换轻微暗场聚焦
- `Esc`: 清空并退出标注层

标注层顶部会显示当前颜色圆点和颜色名称，按 `R` 切换颜色后会立即更新。

## 设置快捷键

点击菜单栏 `✎` 图标，选择 `Settings...`，即可为矩形、箭头、步骤、自由画笔和下一步编号分别设置快捷键。保存后立即生效，并会自动记住配置。

设置页还会列出固定快捷键说明，包括按住 `Shift` 临时显示、`R` 换色、`Z` 撤销、`C` 清空、`Space` 聚焦和 `Esc` 退出。

## 开机启动

构建完成后，可以把这个应用加入 macOS 登录项：

`/Users/mac/Desktop/7654/screen-annotator/dist/ScreenAnnotator.app`

## 打包 DMG

```bash
./scripts/create_dmg.sh 0.1.5
```

生成文件会放在 `dist/ScreenAnnotator-0.1.5.dmg`。

## 说明

默认快捷键是 `Option + 1` 到 `Option + 5`。如果系统提示快捷键注册失败，说明对应组合被其他应用占用了，需要在源码里替换快捷键后重新构建。

## macOS 安全提示

当前 Release 使用本地 ad-hoc 签名，尚未使用 Apple Developer ID 公证。DMG 脚本会在打包前清理扩展属性并严格验证 app bundle 签名，但部分电脑从浏览器下载后，macOS 仍可能提示“不明开发者”。

如果 macOS 明确提示“文件已损坏”，通常是下载隔离属性或未公证导致的 Gatekeeper 拦截，不一定是 DMG 真损坏。

临时解决方式：

```bash
xattr -dr com.apple.quarantine /Applications/ScreenAnnotator.app
open /Applications/ScreenAnnotator.app
```

面向公开用户稳定分发时，需要使用 Apple Developer ID 证书签名并提交 Apple notarization。
