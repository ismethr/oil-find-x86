<p align="center">
  <img src="./assets/readme/hero.svg" width="100%" alt="Oil Find：苹果版的 Everything。按 ⇧⌘F，输入即出结果。">
</p>

> [!NOTE]
> **这是 [Oil Find](https://github.com/oil-oil/oil-find) 的非官方 Intel（x86_64）版本。**
> Oil Find 由 [Lin Zhihuang（oil-oil）](https://github.com/oil-oil) 开发，开源部分以 MIT 许可证发布；本仓库在原作者代码的基础上修改，与原作者无关，问题请在本仓库反馈，不要打扰上游。
>
> **本版本只包含开源的免费版，不含 Oil Find Pro。** 下文提到的 Pro 功能在这里不可用；需要 Pro 请使用[官方版本](https://github.com/oil-oil/oil-find/releases/latest)（仅支持 Apple 芯片）。
>
> 与上游的区别：
> - 编译为 x86_64，可以在 Intel Mac 上运行；文件名匹配使用 AVX2/SSE2 向量加速，关键词搜索比逐字节比较快 3–6 倍。
> - OneDrive、iCloud 云盘等「仅在云端」的文件夹也会列出里面的文件名；应用全程禁止下载云端文件，只取文件名，不取内容。
> - 点击菜单栏图标直接打开搜索，右键点击打开菜单。
> - 不安装上游的自动更新（上游安装包只支持 Apple 芯片）；「检查更新」会打开本仓库的 Releases 页面。

<p align="center">
  <a href="https://github.com/ismethr/oil-find-x86/releases/latest"><b>下载 x86 版</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/oil-oil/oil-find"><b>上游仓库</b></a>
  &nbsp;·&nbsp;
  <a href="https://find.oiloil.org">官网</a>
  &nbsp;·&nbsp;
  <a href="./README.md">English</a>
</p>

<p align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./assets/readme/search-zh-dark.png">
  <img src="./assets/readme/search-zh-light.png" width="100%" alt="Oil Find 的搜索面板：输入 readme，8 条结果按相关度排列，匹配的部分标成蓝色，底栏显示这次搜索用了 0.8 毫秒。">
</picture>
</p>

Oil Find 是 macOS 上的文件搜索工具，思路和 Windows 上的 Everything 一样：自己给磁盘上的文件名建一份内存索引，不依赖 Spotlight。按 ⇧⌘F，屏幕正中弹出搜索框，每打一个字，结果就跟着出来；文件新建、改名、删除，索引都会实时更新。

文件名搜索、已连接的外置磁盘搜索，以及本地 Claude Code、Codex 和 WorkBuddy 话题搜索都免费开源。「全部」会一起搜索文件和话题，也可以切到「AI 话题」分类只搜对话。搜图片和文档里的内容、搜已经拔掉的磁盘，是付费的 [Pro](#oil-find-pro) 功能。

## 为什么快

- **文件名放在一块连续的内存里。** 几十万个名称按列存放，搜索时从头到尾扫一遍，不给每个文件单独创建对象。
- **匹配交给 C 和 NEON。** 字符比较用 Apple 芯片的向量指令批量完成。
- **越打越窄。** 每多打一个字，只在上一次的结果里继续找。
- **只更新变化的部分。** 通过 FSEvents 监听文件变化，增量更新索引；应用重启后从上次停下的位置接着补齐。

下面是在一台 Apple M5（24 GB 内存）上，用仓库自带的命令行工具实测的结果，每条查询跑 20 次取中位数：

| 索引范围 | 文件数 | 建索引 | 常驻内存 | `readme` | `wd`（拼音） | `kind:image` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 默认范围 | 85 万 | 3.0 秒 | 45 MB | 0.6 ms | 0.3 ms | 3.9 ms |
| 整盘 | 750 万 | 27.2 秒 | 343 MB | 8.1 ms | 3.4 ms | 3.8 ms |

默认范围不含开发依赖、应用包内部、资源库和系统目录，需要的话可以在设置里打开。只打一个字母时命中的文件最多，也最慢：默认范围约 11 ms，整盘约 58 ms。

## 搜索语法

| 输入 | 意思 |
| --- | --- |
| `wd`、`wendang` | 拼音首字母或全拼，能找到「文档」 |
| `foo bar` | 同时包含 foo 和 bar |
| `foo \| bar` | 包含 foo 或 bar |
| `readme !node_modules` | 包含 readme，排除 node_modules 里的 |
| `*.png` | 通配符，匹配整个名称 |
| `~/Desktop/ png` | 只在桌面下面找 |
| `ext:pdf;docx` | 按扩展名 |
| `kind:image` | 按类型：folder、app、doc、image、video、audio、code、archive |
| `file:`、`folder:` | 只要文件，或只要文件夹 |
| `size:>10mb`、`size:1mb..5mb` | 按大小 |
| `dm:today`、`dm:week`、`dm:2026-10-01` | 按修改时间 |
| `regex:^IMG_\d+` | 正则表达式 |

从终端或编辑器复制来的路径可以直接粘贴：`file://` 链接、带引号或转义的路径、末尾带 `:行:列` 的路径都能识别。在搜索框里按 ⌘/ 可以随时打开语法速查。

## 键盘操作

| 按键 | 作用 |
| --- | --- |
| <kbd>⇧</kbd><kbd>⌘</kbd><kbd>F</kbd> | 打开搜索，可以在设置里改 |
| <kbd>Return</kbd> | 打开 |
| <kbd>⌘</kbd><kbd>Return</kbd> | 在访达中显示 |
| <kbd>空格</kbd> / <kbd>⌘</kbd><kbd>Y</kbd> | 用 Quick Look 预览（选中结果后按空格） |
| <kbd>⌘</kbd><kbd>C</kbd> / <kbd>⌥</kbd><kbd>⌘</kbd><kbd>C</kbd> | 拷贝路径、拷贝名称 |
| <kbd>⌘</kbd><kbd>⌫</kbd> | 移到废纸篓 |
| <kbd>Tab</kbd> / <kbd>⌘</kbd><kbd>1</kbd>…<kbd>9</kbd> | 切换类型 |
| <kbd>⌘</kbd><kbd>/</kbd> | 语法速查 |

结果也可以直接拖到别的应用里。

## Oil Find Pro

免费版开源，永久免费。Pro 是在它之上的闭源付费功能，一次买断，可以免费试用 7 天。

| | 免费版 | Pro |
| --- | :---: | :---: |
| 按文件名搜索：拼音、通配符、正则，按类型、大小、时间筛选 | ✓ | ✓ |
| 本地 AI 话题：Claude Code、Claude 桌面端 Code 会话、Codex、WorkBuddy | ✓ | ✓ |
| 实时更新、Quick Look 预览、拖放、全键盘操作 | ✓ | ✓ |
| 排除文件夹和文件类型、应用内更新 | ✓ | ✓ |
| 外置磁盘：插上就建立索引，实时更新 | ✓ | ✓ |
| 外置磁盘拔掉后也能搜到 | | ✓ |
| 图片内容：截图、照片里的文字与画面 | | ✓ |
| 文档内容：PDF、Word、PowerPoint、Excel、Pages、Markdown 等 | | ✓ |
| 源码 | 开源，MIT | 闭源 |
| 价格 | 免费 | ¥49（其他地区 $9.99）一次买断 |

Pro 和免费版是同一个安装包：

- 从 Releases 或官网下载后，免费功能直接可用，不激活也不会过期。
- 想用 Pro，在设置的 Oil Find Pro 分区点「免费试用 7 天」，或输入授权码。试用结束只停用 Pro 功能，其他照常。
- 从源码构建得到的是不含 Pro 的免费版。
- 图片和文档都在本机处理，不上传。

购买和详情见 [find.oiloil.org/pro](https://find.oiloil.org/pro)。

## 安装

1. 从 [Releases](https://github.com/oil-oil/oil-find/releases/latest) 下载 `Oil-Find.zip`，解压后把 Oil Find 拖进「应用程序」。
2. 第一次打开时，macOS 会拦下来，因为它没有经过 Apple 公证。到「系统设置 → 隐私与安全性」，在页面下方点「仍要打开」。
3. 按 ⇧⌘F 开始搜索。
4. 可选：授予「完全磁盘访问权限」后，邮件附件和其他应用的数据也能搜到。不授予也能正常使用。

本 x86 版不会自动更新；在菜单里点「检查更新」会打开本仓库的 Releases 页面，下载新版替换即可。

本 x86 版的安装包不含 Pro。

卸载时退出 Oil Find，删掉「应用程序」里的 Oil Find 和 `~/Library/Application Support/Oil Find` 即可。

## 从源码构建

需要 macOS 14 和 Swift 5.10 以上（Xcode 15.3 或更新）。

```sh
git clone https://github.com/oil-oil/oil-find.git
cd oil-find
swift test
scripts/build-app.sh   # 生成 build/Oil Find.app
scripts/install.sh     # 构建并安装到「应用程序」
```

从源码构建得到的是免费版，不含 Pro。自己构建的应用使用临时签名，每次重新构建后，需要重新授予一次完全磁盘访问权限。

## 隐私

- 文件名搜索读取名称、大小和修改时间；本地 AI 话题搜索还会读取 Claude Code、Codex 和 WorkBuddy 保存在本机的标题与对话正文，不会上传。Pro 开启图片或文档内容搜索后，会在本机读取这些文件提取文字，结果同样只存在本机。
- 索引只保存在本机的 `~/Library/Application Support/Oil Find/`。
- 本 x86 版不会自动联网检查更新。
- 使用 Pro 时，授权每天联网校验一次，只发送授权码、设备标识和设备名。

## 目前的限制

- 本仓库只提供 Intel（x86_64）版本，需要 macOS 14 及以上，不含 Pro。
- 不支持网络卷。
- 外置磁盘拔掉后，免费版搜不到上面的文件；Pro 可以。
- AI 话题搜索支持保存在本机的 Claude Code、Claude 桌面端 Code 会话、Codex、WorkBuddy 对话。Claude 普通网页聊天、尚未保存到本机的 WorkBuddy 云端内容，以及 WorkBuddy 已归档或删除的会话、临时 Quick Ask 和子代理会话都不在搜索范围内。Pro 还能搜索图片和文档里的文字。

## 项目结构

| 目录 | 内容 |
| --- | --- |
| `Sources/COilFind` | C 代码：批量读取目录、名称比较、搜索评分 |
| `Sources/OilFindCore` | 扫描、索引、查询、实时更新、持久化、应用更新 |
| `Sources/OilFindApp` | AppKit 应用和设置界面 |
| `Sources/OilFind` | 应用入口 |
| `Sources/oilfind-cli` | 命令行工具，用来测速和排查问题 |
| `site` | 官网 [find.oiloil.org](https://find.oiloil.org) |

索引的数据结构和设计约束见 [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)，开发约定见 [AGENTS.md](./AGENTS.md)。

## 参与贡献

欢迎提 Issue 和 Pull Request。项目只做文件搜索这一件事，匹配、排序、索引、性能和界面方面的改进都欢迎。Pro 功能（图片和文档内容、拔掉的磁盘也能搜）在私有仓库里维护，实现这些功能的 Pull Request 不会合并。

## 许可证

本仓库的代码使用 [MIT](./LICENSE) 许可证。原作版权归 Lin Zhihuang 所有，x86 分支的修改部分版权归 ismethr 所有。Pro 模块不在本仓库里，不开源；Releases 和官网的安装包包含它。
