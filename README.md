本项目基于 [ponyMenu] ([https://github.com/PonyWarrior/PonyMenu]) 进行二次开发，原始项目由 [PonyWarrior](https://github.com/PonyWarrior) 贡献，遵循 MIT 许可证。

提供整合包下载：整合包整合了三个实用 Mod：**Jowday-DamageMeter**、**PonyWarrior-PonyMenu** 和 **PonyWarrior-PonyQOL2**，帮助你优化游戏体验、快速测试构筑或轻松畅玩。以下详细介绍每个 Mod 的功能、使用方法以及安装步骤，助你快速上手！

## 下载地址与视频说明

- **下载地址**: [https://pan.quark.cn/s/a4df0762e9d0](https://pan.quark.cn/s/a4df0762e9d0)
- **视频说明**: [http://www.bilibili.com/video/BV15wngzsEq2](http://www.bilibili.com/video/BV15wngzsEq2)

## 安装方法

### 直接安装：
- 下载整合包后，将文件夹解压并复制到游戏的 `Ship` 目录下。
- 确保目录结构如下：
  ```
  Ship/
  ├── ReturnOfModding/
  │   ├── plugins/
  │   │   ├── Jowday-DamageMeter/
  │   │   ├── PonyWarrior-PonyMenu/
  │   │   ├── PonyWarrior-PonyQOL2/
  │   │   └── ...
  ├── d3d12.dll
  ├── mods.yml
  └── _state
  ```
- 启动游戏，会出现命令行窗口和首次弹窗，点击 `Close` 关闭。
- 按 `Insert` 键可隐藏设置菜单。

### 也可以通过 R2Modman 安装：
- 使用 [R2Modman](https://thunderstore.io/tools/r2modman/) 管理器，搜索并安装 `Jowday-DamageMeter`、`PonyWarrior-PonyMenu` 和 `PonyWarrior-PonyQOL2`。
- 确保安装依赖（如 `ModUtil` 和 `DemonDaemon`）。

### 注意事项：
- 备份存档以防万一。

## Mod 整合包目录说明

整合包包含以下关键文件和文件夹：
- **ReturnOfModding/**: 包含所有 Mod 的核心文件。
    - `plugins/Jowday-DamageMeter/`: 伤害统计器插件。
    - `plugins/PonyWarrior-PonyMenu/`: 作弊/测试菜单插件。
    - `plugins/PonyWarrior-PonyQOL2/`: 生活质量增强插件，包含 `config.lua` 用于自定义功能开关。
- **d3d12.dll**: Mod 加载器必需文件。
- **mods.yml**: 定义 Mod 加载顺序和依赖。
- **_state**: 存储 Mod 运行状态。

## Jowday's DPS Meter (Jowday-DamageMeter)

**原作者与仓库**：
- 作者：Jowday
- Thunderstore: [https://thunderstore.io/c/hades-ii/p/Jowday/DamageMeter/](https://thunderstore.io/c/hades-ii/p/Jowday/DamageMeter/)
- Nexus Mods: [https://www.nexusmods.com/hades2/mods/4](https://www.nexusmods.com/hades2/mods/4)

这个 Mod 在屏幕左下角显示实时伤害统计，帮助分析输出来源和构筑效率，适合优化武器搭配或 boss 战测试。支持中文界面。`Ctrl + Y` 切换显示。

### 主要功能
- 实时显示攻击、特殊技能、冲刺等伤害来源的彩色条形图（默认开启）。
- 支持 Omega 技能单独统计，可选合并显示（默认分离）。
- 显示 boon 图标（默认开启，可关闭），精准追踪 Duo boon 等伤害贡献。
- 多语言支持，自动适配简体中文等（默认开启）。

### 使用方法
1. 进入跑图后，左下角自动显示计量器，观察伤害分布（如绿色条为 Poseidon boon，红色条为 Ares）。
2. 调整设置：在 R2Modman 的 config 文件夹中，修改：
    - `SplitOmega = false`：合并 Omega 条。
    - `ShowIcons = false`：关闭 boon 图标。
3. 使用快捷键（默认 `Ctrl+Y`）隐藏/显示界面。

### 提示
- 结合 PonyMenu 测试 boon 构筑，分析输出效率。

## Pony Menu (PonyWarrior-PonyMenu)

**原作者与仓库**：
- 作者：PonyWarrior
- GitHub: [https://github.com/PonyWarrior/PonyMenu](https://github.com/PonyWarrior/PonyMenu)
- Thunderstore: [https://thunderstore.io/c/hades-ii/p/PonyWarrior/PonyMenu/](https://thunderstore.io/c/hades-ii/p/PonyWarrior/PonyMenu/)
- Nexus Mods: [https://www.nexusmods.com/hades2/mods/2](https://www.nexusmods.com/hades2/mods/2)
- 我的仓库地址：[https://github.com/liwenhao0427/PonyMenu](https://github.com/liwenhao0427/PonyMenu)

**本整合包新增内容**：
- 在原 Mod 基础上，我添加了额外作弊功能，包括无限 Roll、强制混沌门、必出英雄祝福、击杀掉落祝福、0 元购、魔宠解锁等，提升测试和爽玩体验。

Pony Menu 是一个全能作弊/测试菜单，在物品栏中添加“小马祝福菜单”标签，方便生成祝福、材料或挑战 boss。界面全中文化，适合快速测试或爽玩。

### 主要功能
- **祝福管理**：
    - 一键清除所有祝福（包括阿卡纳牌）。
    - 祝福选择器：原地生成祝福，设为普通/稀有/史诗/英雄/传奇。
    - 祝福管理器：升级/降级/删除已有祝福。
- **资源与物品**：
    - 生成任意数量材料（如黑暗、宝石）。
    - 立即获得 Charon 商店或地图物品。
- **构建与战斗**：
    - 区域守卫选择器：保存构筑后直接挑战 boss。
    - 存入/加载套装：保存或加载魔宠、祝福、饰品组合。
    - 自杀：立即返回 Crossroads。
- **额外作弊**：
    - 无限 Roll、强制混沌门、必出英雄祝福。
    - 敌人击杀掉落祝福、混沌祝福可重复。
    - 增加冲刺次数、+100 金币、恢复生命/魔力。
    - 解锁魔宠（鸦鸦、蛙蛙、猫猫、狗狗、鼬鼬）。
    - 商店 0 元购（包括局内外、塔罗牌）。
    - 优先触发故事房，减速效果影响计时器。

### 使用方法
1. 按 `I` 打开物品栏，最后一栏打开，点击功能按钮（有中文提示）。
2. 测试构筑：可以选择自定义祝福，用 `SaveState` 保存套装，之后可以在任意时刻加载这套构筑（退出游戏后重置）可以直接选择 Boss 挑战。
3. 启用额外功能：在菜单中点击“作弊菜单”。

## Pony's Quality of Life 2 (PonyWarrior-PonyQOL2)

**原作者与仓库**：
- 作者：PonyWarrior
- GitHub: [https://github.com/PonyWarrior/PonyQOL2](https://github.com/PonyWarrior/PonyQOL2)
- Thunderstore: [https://thunderstore.io/c/hades-ii/p/PonyWarrior/PonyQOL2/](https://thunderstore.io/c/hades-ii/p/PonyWarrior/PonyQOL2/)
- Nexus Mods: [https://www.nexusmods.com/hades2/mods/16](https://www.nexusmods.com/hades2/mods/16)（不再维护，转至Thunderstore）

QOL2 提供生活质量改进，优化跑图流程，适合长时间游玩或超宽屏玩家。功能无缝融入游戏，默认开启核心功能。

### 主要功能
- 优先触发故事房间，推进剧情（默认开启）。
- Boss 血条显示精确数值（默认开启）。
- 随时退出游戏，无需强制完成跑图（默认开启）。
- 门上显示图标（喷泉、资源等），优化路径选择（默认开启）。
- 混沌试炼可重复，显示未解锁试炼（默认开启）。
- 跳过冗长动画（死亡、结局、对话等，部分默认开启，部分需 config 调整）。
- 超宽屏优化，去除黑边（默认关闭）。
- 显示冲刺命中框，练习连招（默认开启，但是我的整合包默认关闭）。
- 减速效果（如 Poseidon）延长计时器（默认开启）。
- 永久显示剩余房间数（默认开启）。
- Aphrodite boon 高亮附近敌人（默认开启）。
- 无敌模式（默认关闭，需 config 启用）。

### 使用方法
1. 功能自动生效，如门上图标、Boss 血量显示等。
2. 调整设置：在 `ReturnOfModding\plugins\PonyWarrior-PonyQOL2\config.lua` 启用/禁用功能（如 `GodMode = true`）。
3. 检查效果：跑图时观察门图标或血量数值。

### 提示
- 与 PonyMenu 搭配，用菜单生成 boon 后，用 QOL2 的高亮功能测试效果。
- 超宽屏玩家可启用 `Ultrawide` 优化显示。

# 更新说明
- 2025.09.28 修复重复祝福管理器bug、修复局内物品不生效bug
- 2025.09.26 修复箭头bug
- 2025.06.26 修复局外使用繁星之路报错的bug,但仍然需要有月神祝福
- 2025.06.24 新增解锁魔宠功能，修复Boss挑战报错
- 2025.06.23 修复点击降低稀有度时报错，修复无法取消无限Roll的bug
- 2025.06.22 物品改为直接掉落，物品栏修复适配版本更新
- 2025.06.18 修复版本更新引起的bug，临时处理
- 2025.03.14 一些旧的被删除祝福；新增0元购，支持塔罗牌；
- 2025.03.01 从 https://github.com/PonyWarrior/PonyQOL2 项目抄了一些代码
- 2025.03.01 添加了废弃的匕首改造八面神锋
- 2025.03.01 新增自定义祝福，但是文本描述因为需要修改游戏本地化文件，暂不支持
- 2025.03.01 修复无限roll不生效bug及本地化
- 2025.02.24 修复Boss直战在某些情况下报错的bug
- 2025.02.24 调整一下按键位置，Boss挑战校验缓存避免报错
- 2025.02.23 消耗品改为创建在地上
- 2025.02.23 增加 立刻挑战Boss功能
- 2025.02.23 增加 消耗品使用功能
- 2025.02.23 增加 酒神、雅典娜、美狄亚、伊卡洛斯、喀耳刻
- 2025.02.22 适配了最新游戏版本，增加了战神阿瑞斯的祝福管理 
