# Crown Gambit Demo 简体中文汉化

这是一个**非官方**的《Crown Gambit》Steam 试玩版(Demo)简体中文汉化补丁。

Demo 本身不带中文,而玩家社区已有的汉化(见下方致谢)只支持正式版 1.0.6。
本仓库做的事:把那份汉化**适配到 Demo 版**,并提供一键安装脚本。

> **致谢(重要)**
> 全部中文翻译资源来自 **[GreyWolf1101/Crown-Gambit-Simplified-Chinese](https://github.com/GreyWolf1101/Crown-Gambit-Simplified-Chinese)**(v1.2.7),
> 37 万字剧情与全部 UI 文本的翻译、润色工作均由原作者完成,本仓库不重新分发其文件——
> 安装脚本会在安装时**直接从原作者的 Release 下载**并校验 SHA-256。
> 本仓库仅包含为适配 Demo 而修改的 `project.binary`(30 KB)与安装脚本。

---

## 适用于

- Steam Windows 版 **Crown Gambit Demo**(游戏内部版本 1.0.3,Steam build 18883383)
- 不适用于正式版(正式版请直接使用上面原作者的补丁)

## 安装方法

1. 关闭游戏。
2. **下载本仓库全部文件**(Code → Download ZIP,或克隆),保持目录结构:
   ```
   Crown-Gambit-Demo-Simplified-Chinese\   ← 放进游戏目录
   ├── resources\project.binary
   ├── install_zh_demo.ps1
   └── 安装中文补丁.bat
   ```
3. 把整个文件夹放入 Demo 游戏目录(即能看到 `crown_gambit_windows.exe` 的目录)。
4. 双击 `安装中文补丁.bat`,等待完成(脚本会自动下载汉化素材约 46 MB,重建约 7.4 GB 的 PCK,共需 10–20 分钟,期间需要约 16 GB 临时磁盘空间)。
5. 从 Steam 启动游戏,应为简体中文。若没有自动切换,进游戏设置选"简体中文"。

脚本会自动校验游戏版本与下载文件的哈希,版本不符会拒绝安装,不会损坏游戏。

## 还原英文原版

两种方式任选:

- Steam → 右键游戏 → 属性 → 已安装文件 → **验证游戏文件完整性**(会重新下载原版 PCK);
- 游戏目录里若存在 `crown_gambit_windows.before_zh.pck`(安装脚本自动创建的硬链接备份),可用它覆盖 `crown_gambit_windows.pck`。

⚠️ **注意**:卸载游戏、验证文件或重装前,请先把游戏内语言切回 English(或删除
`%APPDATA%\CROWN_GAMBIT\user_settings.tres`),否则原版主菜单会因不认识 `zh` 语言而无法操作。

## 常见问题

- **Steam 更新/验证后汉化消失了?** 正常现象,重新跑一遍 `安装中文补丁.bat` 即可。
- **游戏更新后脚本报"Unsupported game files"?** 说明 Demo 版本变了,需要等适配更新;请勿强行安装。
- **报"空间不足"?** 安装期间临时需要约 16 GB 空闲磁盘(游戏所在分区)。
- **只想省空间?** 安装完成并确认游戏正常后,可删除游戏目录里的 `crown_gambit_windows.before_zh.pck` 备份(约 7.4 GB)。

## 原理

Demo 与正式版 1.0.6 的剧情文本完全一致(41,401 行),因此 v1.2.7 的中文资源可直接复用。
本补丁用 [GDRE Tools](https://github.com/bruvzg/gdsdecomp)(MIT 许可,随原补丁分发)对 Demo 的 PCK 做
`--pck-patch`:替换/新增 13 项资源(中文翻译、中文剧情 ink、中文字体相关场景与脚本),其中
`project.binary` 为 Demo 原文件的修改版——仅在语言列表中注册了 `res://lang/translations.zh.translation`。

## 免责声明

- 本项目仅供学习交流,游戏内容版权归 [WILD WITS GAMES](https://wildwitsgames.com/) 与 [Serenity Forge](https://serenityforge.com/) 所有;请支持正版。
- 翻译版权归 GreyWolf1101 所有;若原作者或版权方要求下架,本仓库将立即处理。
- 本仓库不包含、也不重新分发任何游戏本体资源文件。
