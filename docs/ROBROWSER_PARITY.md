# RagnarokGame 对齐 roBrowserLegacy 补齐清单

- 生成日期：2026-09-30
- 对比基准：
  - ragnarok-offline `dc364b87`：`Packages/RagnarokGame`，以及它依赖的 `RagnarokNetwork`、`RagnarokPackets`、`RagnarokModels`、`RagnarokEffects`、`RagnarokRendering`、`RagnarokRenderAssets`、`RagnarokSprite`、`RagnarokResources`、`RagnarokLocalization`
  - roBrowserLegacy `58759ab2`：`src/`
- 对比方法：逐个模块对照 roBrowserLegacy 的 `Engine/*`、`Engine/MapEngine/*`（包订阅与发送）、`Renderer/*`、`Controls/*`、`UI/Components/*`、`Preferences/*`、`DB/*`，再和 RagnarokGame 的 `GameSession.handle*Packet`、`PacketFactory`、`MapScene`、`MapSceneRuntime`、`UI/*` 的现有实现核对。

## 约定

- 优先级
  - **P0**：核心玩法闭环里缺的东西。不补，基本玩法就明显残缺，或者画面、信息缺得厉害。
  - **P1**：常规 RO 体验必需，比如组队、交易、摆摊、状态图标、公告。
  - **P2**：进阶系统或职业专属系统，比如公会、生命体、邮件、精炼。
  - **P3**：边缘功能、运营类功能、GM 功能、画质增强，或只在多版本兼容时才需要的功能。
- 包名统一用 rAthena 命名（`ZC_*`、`CZ_*`、`HC_*`、`CH_*`、`AC_*`、`CA_*`）。`(1–5)` 表示同一语义有多个版本。当前 `PACKET_VERSION = 20211103` 是编译期常量，每项只需实现这个版本对应的那一个包。
- `RagnarokPackets` 已从 rAthena 生成了 715 个包结构，所以大多数条目的工作量在这几处：`PacketFactory` 构造、`GameSession` 分发、`RagnarokModels` 模型、`MapScene` 表现和 SwiftUI 窗口。
- 每一条都注明了 roBrowserLegacy 的参考实现路径（相对 `roBrowserLegacy/src/`）。

---

## 0. 总览

| 维度 | roBrowserLegacy | RagnarokGame 现状 |
| --- | --- | --- |
| 订阅的服务端包 | 约 551 个（含版本变体） | `GameSession` 里有 111 个 `case`，其中 21 个是空处理 |
| 发送的客户端包 | 约 270 种 | `PacketFactory` 里有 44 个构造器 |
| UI 组件 | 100 个（`UI/Components/*`） | 约 30 个 SwiftUI 视图；菜单里 14 个按钮处于禁用状态 |
| 特效表 `EffectTable` | 约 615 个 EffectID | 46 个 |
| 技能特效 `SkillEffect` | 约 1013 个技能 | 23 个 |
| 程序化特效 / 后处理 | 30 多个自定义 WebGL 特效，外加 9 个后处理着色器 | 0 |
| 斜杠命令 | 60 多个，另有表情命令 | 0（只有 @ 命令快捷发送） |
| 偏好设置 | 7 组持久化偏好 | 无 |

---

## 1. 已具备的基线能力

以下能力已经有了。本清单只记录它们需要增强的地方。

- 登录流程：登录 → 选服 → 选角 / 创角（含预览）/ 预约删除 → 进图。登录服、角色服、地图服各有一个 keepalive；有断线提示和封禁提示。
- 地图：GND、GAT、RSW 加载；RSM 模型（含动画）；水面、光照贴图、阴影图、雾；RSW 环境特效、环境音效和 BGM。
- 实体
  - 已实现：出现、行走（本地寻路插值）、停止、消失（死亡淡出、传送特效）、复活、转向，以及部分 Look 变更（职业、发型、武器、盾、头饰、发色、衣色、披风）。
  - cloak 状态会隐藏实体。
  - 已有动作：攻击、坐下、拾取、施法。
  - 已有施法条，以及自己和已知 HP 的怪物的 HP/SP 条。
- 伤害数字：伤害、Miss、连击、HP/SP 恢复。
- 特效
  - 支持的特效类型：STR、SPR、2D、3D、Cylinder、WAV。
  - 已有的表现：按元素区分的施法魔法阵、升级特效、传送阵特效、弓箭投射物。
- 物品
  - 背包（3 个页签）：使用、装备、卸下、按数量丢弃。
  - 地面物品：拾取。
  - 箭矢装备、装备窗口、物品描述和卡片显示。
- 技能：技能列表、升级、使用（自动选最近的怪物）、地面技能、传送之阵的地点列表、自动施放。
- 快捷栏：与服务端同步、拖拽、切换行。
- NPC：对话、菜单、数字 / 文本输入、选择买或卖、买卖、仓库。
- 聊天
  - 能接收公共、私聊、组队、公会、氏族和 NPC 消息，但只能发送公共消息。
  - 消息中心会显示拾取、装备、经验和技能失败提示。
  - 有 @ 命令快捷发送。
- HUD 和窗口：基本信息、状态加点（6 项基础属性）、小地图（可缩放）、世界地图（通过 @warp 传送）。
- 选项菜单：回存档点、回选角、退出。
- 移动端操作：摇杆、动作盘、镜头旋转、俯仰和缩放。

---

## 2. 修正项：已有实现与 roBrowser 行为不一致

- [ ] **P0** 技能目标选择
  - 现状：`MapScene.useSkillOnNearestMonster` 总是打最近的怪物；辅助技能只能对自己放，无法治疗或加持他人。
  - 需要：改成与 roBrowser 一致的目标选择流程，见 §8.1。
  - 参考：`UI/Components/SkillTargetSelection/SkillTargetSelection.js`
- [ ] **P1** 自动施放（`ZC_AUTORUN_SKILL`，用于卷轴、随机魔法）
  - 现状：直接打最近的怪物。
  - 需要：roBrowser 会进入目标选择状态，这里应当一致。
  - 参考：`Engine/MapEngine/Skill.js#onAutoCastSkill`
- [ ] **P1** 退出游戏
  - 现状：`OptionsView` 发出 `CZ_REQUEST_QUIT` 后立刻 `exitSession()`，没有等服务端回复。
  - 需要：处理 `ZC_ACCEPT_QUIT` 和 `ZC_REFUSE_QUIT`。战斗中服务端会拒绝退出，需要显示提示。
  - 参考：`Engine/MapEngine.js#onExitSuccess/onExitFail`
- [ ] **P1** 点击实体的分发不完整（`MapScene.handleInteraction`）
  - `npc2`（objecttype `0xC`）类型的 NPC 点击后没有反应，应当和 `npc` 一样对话。
  - 传送点（job 45，即 `JT_WARPNPC`）点击后会发 `CZ_CONTACTNPC`，应当改为走进传送点。
  - 点击 PC、宠物、生命体、佣兵时没有反应（缺上下文菜单，见 §15.7）。
  - 和 NPC 对话时角色应当转向 NPC（发送 `CZ_CHANGE_DIRECTION`）。`PacketFactory.CZ_CHANGE_DIRECTION` 已存在，但没有调用方。
  - 参考：`Controls/EntityControl.js`
- [ ] **P1** 删除角色
  - 现状：`CH_DELETE_CHAR3` 固定发送空的生日。
  - 需要：让用户输入生日或邮箱，处理预约删除的剩余时间和取消删除，见 §3。
- [ ] **P1** 聊天颜色
  - 现状：`ChatMessage.color` 和 `MessageCenter.MessageType` 在 UI 里一律渲染成白色。
  - 需要：按消息类型着色，并支持 NPC 自定义颜色和 `ZC_MSG_COLOR`。
- [ ] **P1** 时间同步
  - 现状：发出了 `CZ_REQUEST_TIME`，但没有处理 `ZC_NOTIFY_TIME` 回包。
  - 需要：用服务器 tick 校准移动和动作时间。
  - 参考：`Engine/MapEngine.js#onPong`
- [ ] **P1** 地图加载完成后的收尾，对齐 roBrowser `onMapChange`
  - `PACKETVER >= 20130320` 时需要发送 `CZ_BLOCKING_PLAY_CANCEL`。
  - 显示地图名提示（`MapName`）。
  - 用 `Announce` 显示倍率信息。
  - 加载城镇招牌（Signboard）。
- [ ] **P1** 死亡界面的“原地复活”按钮
  - 现状：一直处于禁用状态。
  - 需要：背包里有齐格弗里德之证时启用，发送 `CZ_STANDING_RESURRECTION`。
  - 参考：`Engine/MapEngine.js#onResurectionRequest`、`Entity.js#haveSiegfriedItem`
- [ ] **P2** 受击动作
  - 现状：`onMapObjectActionPerformed` 只驱动攻击方，被攻击方不会播放 hurt 动作。
  - 需要：被攻击方播放 hurt，endure 时不播。
  - 参考：`Engine/MapEngine/Entity.js#onEntityWillBeHitSub`

---

## 3. 登录服与角色服

- [ ] **P1** PIN 码
  - 服务端开启 PIN 后会发 `HC_SECOND_PASSWD_LOGIN`，当前是空处理，界面会卡住。
  - 需要：`CH_PINCODE_CHECK`、`CH_PINCODE_FIRST_PIN`、`CH_PINCODE_CHANGE`、`CH_PINCODE_REQUEST`。
  - 需要：PIN 输入窗口。数字键盘用服务端下发的 seed 打乱顺序。
  - 需要：分别处理 `HC_SECOND_PASSWD_LOGIN` 的各个 state，包括首次设置、校验、修改、失败次数。
  - 参考：`Engine/CharEngine.js`、`UI/Components/PincodeWindow/`
- [ ] **P1** 删除角色的完整流程
  - `HC_DELETE_CHAR3_RESERVED` 回包后，显示预约删除时间和剩余倒计时。
  - 到期后再确认删除，并输入生日或邮箱。
  - 支持取消删除：`CH_DELETE_CHAR3_CANCEL` / `HC_DELETE_CHAR3_CANCEL`。
  - 处理旧版的 `HC_ACCEPT_DELETECHAR` / `HC_REFUSE_DELETECHAR` 结果提示。
  - 参考：`CharEngine.js#onDeleteRequest/onCancelDeleteRequest/onDeleteReqDelay`
- [ ] **P2** 角色列表分页和分块下发
  - 需要：`HC_ACCEPT_ENTER_NEO_UNION_LIST(2)`、`HC_ACCEPT_ENTER_NEO_UNION_HEADER`、`HC_CHARLIST_NOTIFY`、`CH_CHARLIST_REQ`、`HC_BLOCK_CHARACTER`（角色被封禁时标记出来）。
  - 参考：`CharEngine.js#onCharacterListChunk`
- [ ] **P2** 选角被拒：处理 `HC_REFUSE_SELECTCHAR`，显示提示。
- [ ] **P2** 地图不可进入
  - 现状：收到 `HC_NOTIFY_ACCESSIBLE_MAPNAME` 时只显示错误。
  - 需要：让用户从可用地图里选一个，发送 `CH_SELECT_ACCESSIBLE_MAPNAME`。
  - 参考：`CharEngine.js#onMapUnavailable`
- [ ] **P2** 创角支持选择种族（人类 / 多拉姆，job 4218），以及网格式发型选择。
  - 参考：`UI/Components/CharCreate/CharCreateCommon.js`（V3/V4）
- [ ] **P3** 登录拒绝的其他变体：`AC_REFUSE_LOGIN_EX`、`AC_REFUSE_LOGIN_USA`、`AC_LOGIN_TAREN_REFUSE(2)` 的提示文案。
- [ ] **P3** 客户端校验包：`CA_EXE_HASHCHECK`、`CA_LOGIN_HAN`（部分服务端需要）。
- [ ] **P3** 登录窗口记住账号（roBrowser `WinLogin` 会保存用户名）。

---

## 4. 网络与协议层

- [ ] **P1** 切换地图服务器
  - 需要：处理 `ZC_NPCACK_SERVERMOVE(2)`。流程是断开当前地图服 → 连接新的 ip:port → 发 `CZ_ENTER` → 加载地图。
  - 多地图服部署时这是必需的。当前没有处理，跨服传送会卡住。
  - 参考：`Engine/MapEngine.js#onServerChange`
- [ ] **P1** 服务端配置
  - 处理 `ZC_CONFIG`、`ZC_CONFIG_NOTIFY(1–4)`，发送 `CZ_CONFIG`。
  - 涉及的开关：公开装备、宠物自动喂食、生命体自动喂食、允许被召集（`/call`）。
  - 参考：`Engine/MapEngine.js#onConfig/onConfigNotify/onConfigUpdate`
- [ ] **P2** 运行时选择 PACKETVER
  - 当前 `PACKET_VERSION` 是编译期常量。
  - roBrowser 支持 2003–2025 共 23 组包长表，并能按客户端 exe 日期自动识别版本。
  - 要做到这一点，需要把 `RagnarokPackets` 的版本分支改成运行时判断。
  - 参考：`Network/PacketVerManager.js`、`PacketVersions.js`、`Packets/packets20xx_len_main.js`
- [ ] **P3** Hercules 包混淆 key（`packetKeys` 配置）。
  - 参考：`Network/PacketCrypt.js`
- [ ] **P3** 心跳变体：`CZ_HBT`（`sec_HBT` 配置）、`CZ_REQUEST_TIME2`、`CZ_PING`。
  - 在固定 PACKETVER 下，`RagnarokPackets` 的 packetdb 已经按版本选好了 opcode。这些只在运行时多版本时才需要。
- [ ] **P3** 新版分块列表：`ZC_SPLIT_SEND_ITEMLIST_NORMAL/EQUIP(2)`、`ZC_SPLIT_SEND_ITEMLIST_SET/RESULT`（2023 年以后的版本才需要）。

---

## 5. 地图会话与地图状态

- [ ] **P1** 地图属性
  - 需要：`ZC_MAPPROPERTY`、`ZC_MAPPROPERTY_R2`、`ZC_NOTIFY_MAPPROPERTY(2)`。
  - 用途：标记 PvP / GvG / 攻城战地图，控制 PvP 计数和计时 UI 的显隐，以及是否显示伤害。
  - 参考：`Engine/MapEngine/MapState.js`、`DB/Map/MapState.js`
- [ ] **P1** mapflag 天气和环境效果：雪、雨、雾、樱花、落叶、烟花、云、夜晚。
  - 参考：`Renderer/ScreenEffectManager.js#startMapflagEffect/setNight`、`DB/Effects/WeatherEffect.js`
- [ ] **P2** 地图格子类型变更
  - 需要：处理 `ZC_UPDATE_MAPINFO`，同步更新 `MapGrid` 和 `PathFinder`。
  - 参考：`Engine/MapEngine/Main.js#onUpdateMapInfo`
- [ ] **P2** 地图信息提示 `ZC_NOTIFY_MAPINFO`，比如“该地图禁止记录传送点”。
- [ ] **P2** PvP 排名 `ZC_NOTIFY_RANKING`，以及 PvP 计数和计时窗口。
  - 参考：`UI/Components/PvPCount/`、`PvPTimer/`
- [ ] **P3** 倍率和个人加成信息：`ZC_PERSONAL_INFORMATION(2)`。
  - 参考：`Main.js#onRatesInfo`

---

## 6. 实体：数据、状态与外观

### 6.1 实体信息

- [ ] **P0** 实体名字
  - 需要：发送 `CZ_REQNAME(2)`，处理 `ZC_ACK_REQNAME`、`ZC_ACK_REQNAMEALL(1–3)`。
  - 要显示的内容：玩家名、组队名、公会名、职位、称号，以及怪物名和 NPC 名。
  - 显示规则：常驻显示，鼠标悬停时高亮，受 `/showname` 偏好控制。
  - 组队成员的名字要用 `partyColors` 着色。
  - 参考：`Engine/MapEngine/Entity.js#onEntityIdentity`、`Renderer/Entity/EntityDisplay.js`
- [ ] **P2** 按 GID 查角色名
  - 需要：`CZ_REQNAME_BYGID(2)` / `ZC_ACK_REQNAME_BYGID(2)`。
  - 用途：邮件、组队、公会里只有 CID 的场景。
  - 参考：`DB/DBManager.js`
- [ ] **P1** 怪物血条
  - 需要：`ZC_HP_INFO_TINY`（百分比血条），并在怪物受到伤害时自动显示血条。
  - 参考：`Entity.js#onEntityLifeUpdate/onEntityLifeUpdateTiny`、`Renderer/Entity/EntityLife.js`
- [ ] **P2** 称号：`CZ_REQ_CHANGE_TITLE` / `ZC_ACK_CHANGE_TITLE`，显示在名字旁边。
- [ ] **P2** NPC 外观变更：`ZC_NPCSPRITE_CHANGE`。
- [ ] **P2** 补齐 Look 变更
  - 现状：`onMapObjectSpriteChanged` 只处理了一部分。
  - 需要补的：`LOOK_BODY2`（时装外观，对应 `ComposedSprite.Configuration.outfit`，目前一直是 0）、`LOOK_SHOES`，以及坐骑相关的外观。
  - 参考：`Entity.js#onEntityViewChange`

### 6.2 状态外观（`StatusChangeOption*`）

- [ ] **P1** bodyState（opt1）
  - 包括：石化（两个阶段）、冰冻、昏迷、睡眠、灼烧、禁锢。
  - 表现：精灵着色（灰、蓝等）、动作冻结、附加特效。
  - 现状：只存了值，没有用在渲染上。
  - 参考：`Renderer/Entity/EntityState.js#updateBodyState`
- [ ] **P1** healthState（opt2）
  - 包括：中毒、诅咒、沉默、混乱、黑暗、出血。
  - 表现：着色和头顶特效；中毒和黑暗还要叠加屏幕效果。
  - 参考：`EntityState.js#updateHealthState`、`Renderer/Effects/PoisonEffect.js`、`Renderer/Effects/Shaders/Blind.js`
- [ ] **P1** effectState（option）
  - 包括：Sight、Ruwach、Hide、Cloaking、Chase Walk（半透明）、Invisible、手推车、猎鹰、Peco / 龙 / 狮鹫 / 魔导机甲、狼、兽人头、婚纱、圣诞装、夏装、韩服、啤酒节服装等。
  - 现状：只处理了 cloak。
  - 参考：`EntityState.js#updateEffectState/updateAllRidingState`
- [ ] **P1** virtue（opt3）
  - 包括：Quicken、Overthrust、Energy Coat、爆气、金刚、Blade Stop、狂暴、Assumptio、Marionette、Warm 等持续特效。
  - 需要：处理 `ZC_STATE_CHANGE3`，并在 `ZC_MSG_STATE_CHANGE` 里联动。
  - 参考：`EntityState.js#updateVirtue`

### 6.3 附属实体与坐骑

- [ ] **P1** 手推车
  - 需要：手推车精灵（14 种样式）和影子，挂在角色身后并跟随移动。
  - 相关包：`ZC_SELECTCART` / `CZ_SELECTCART`、`CZ_REQ_CHANGECART`、`CZ_REQ_CARTOFF`。
  - 参考：`Renderer/Entity/EntityView.js`、`UI/Components/ChangeCart/`、`CartDecoration/`
- [ ] **P1** 坐骑
  - 包括：Peco、龙、狮鹫、魔导机甲、全职业坐骑（`AllMountTable`）、服务端下发坐骑 job 时的回退映射（`MountTable`）。
  - 参考：`DB/Jobs/MountTable.js`、`AllMountTable.js`、`EntityView.js`
- [ ] **P1** 猎鹰和狼
  - 需要：作为独立实体跟随主人，进图时根据 effectState 重建。
  - 参考：`Engine/MapEngine.js#onMapChange`（`_FALCON` / `_WUG`）
- [ ] **P1** 气功球 `ZC_SPIRITS(2)`、千年盾 `ZC_MILLENNIUMSHIELD`、Warlock 元素球。
  - 参考：`Renderer/Effects/SpiritSphere.js`、`WarlockSphere.js`、`Entity.js#updateWarlockSpheres`
- [ ] **P2** 99 级 / 175 级光环，受 `/aura` 和 `/aura2` 控制。
  - 参考：`Renderer/Entity/EntityAura.js`、`Effects/Level99Bubble.js`
- [ ] **P2** 头饰特效 `ZC_HAT_EFFECT`，以及装备附带的持续特效。
  - 参考：`DB/Items/HatTable.js`、`ItemEffect.js`、`Entity.js#onHatEffects`
- [ ] **P2** 武器挥动拖尾。
  - 参考：`DB/Items/WeaponTrailTable.js`、`Renderer/Effects/Trail.js`
- [ ] **P2** 公会徽章显示在名字旁边。
  - 相关包：`ZC_GUILD_EMBLEM_IMG`、`CZ_REQ_GUILD_EMBLEM_IMG`。
  - 参考：`Renderer/Entity/EntityEmblem.js`
- [ ] **P3** GR2（Granny）3D 怪物模型（`data/model/3dmob/`），缺模型时回退为波利。
  - 参考：`Loaders/GR2Loader.js`、`Renderer/GR2/`

### 6.4 头顶 UI

- [ ] **P0** 头顶聊天气泡
  - 现状：`ZC_NOTIFY_CHAT` 只进聊天框。
  - 参考：`Renderer/Entity/EntityDialog.js`、`Entity.js#onEntityTalk/onEntityTalkColor`
- [ ] **P1** 表情
  - 需要：处理 `ZC_EMOTION`，发送 `CZ_REQ_EMOTION`。
  - 入口：表情窗口（Alt+L）、`/表情` 命令、Ctrl+数字的表情快捷键（`EXECUTE_FLAG_*`，可自定义）。
  - 参考：`Entity.js#onEntityEmotion`、`DB/Emotions.js`、`UI/Components/Emoticons/`、`UI/Components/ShortCuts/ShortCuts.js#executeFlag`
- [ ] **P1** 聊天室、摊位和收购店的招牌
  - 相关包：`ZC_ROOM_NEWENTRY`、`ZC_DESTROY_ROOM`、`ZC_STORE_ENTRY`、`ZC_DISAPPEAR_ENTRY`、`ZC_BUYING_STORE_ENTRY`、`ZC_DISAPPEAR_BUYING_STORE_ENTRY`、`ZC_STORE_ASSISTANT_ENTRY(_V2)` / `DISAPPEAR`。
  - 点击招牌后分别进入聊天室、摊位或收购店。
  - 参考：`Renderer/Entity/EntityRoom.js`、`UI/Components/EntityRoom/`、`EntitySignboard/`
- [ ] **P2** 任务 NPC 头顶图标：`ZC_QUEST_NOTIFY_EFFECT`。
  - 参考：`Entity.js#onEntityQuestNotifyEffect`
- [ ] **P2** 头顶脚本文字：`ZC_SHOWSCRIPT`。
- [ ] **P2** 城镇招牌（3D 招牌，数据来自 signboardlist）。
  - 参考：`Renderer/SignboardManager.js`、`DB.getAllSignboardsForMap`

### 6.5 特殊移动与动作

- [ ] **P1** 击退滑动 `ZC_FASTMOVE`，跳跃 `ZC_HIGHJUMP`（跆拳道高跳、Snap 等）。
  - 参考：`Entity.js#onEntityFastMove/onEntityJump`
- [ ] **P1** 带位移的攻击和技能：`ZC_NOTIFY_ACT_POSITION`、`ZC_NOTIFY_SKILL_POSITION`（冲锋攻击等）。
- [ ] **P2** `ZC_NOTIFY_ACTENTRY`：进入视野的同时带动作。
- [ ] **P2** 真剑白刃取 `ZC_BLADESTOP` 的表现。
- [ ] **P1** 坐下和站起
  - 需要：`/sit`、`/stand`、Insert 键，发送 `CZ_REQUEST_ACT`（type 2/3）。
  - 现状：`GameSession.requestAction` 已存在，但没有 UI 入口。
- [ ] **P2** 转身和转头
  - 需要：`/doridori`（`CZ_DORIDORI`）、`/bangbang`、`/bingbing`；Shift + 右键原地转向；发送 `CZ_CHANGE_DIRECTION`。
- [ ] **P2** 物品掉落
  - 需要：`ZC_ITEM_FALL_ENTRY` 的 subX/subY 偏移和掉落弹跳动画。
  - 需要：按物品等级显示掉落光柱（`showdropeffect` / `dropeffectmode`）。
  - 参考：`Renderer/ItemObject.js`、`Renderer/Entity/EntityDropEffect.js`

### 6.6 MVP 与 Boss

- [ ] **P2** MVP
  - 需要：`ZC_MVP`（MVP 特效）、`ZC_MVP_GETTING_ITEM`（奖励提示）。
  - 参考：`Entity.js#onEntityMvpReward/onMarkMvp`
- [ ] **P2** Boss 雷达和刷新时间提示：`ZC_BOSS_INFO`。

---

## 7. 战斗表现

- [ ] **P1** 伤害数字补齐
  - 暴击：带背景气泡，`Damage.TYPE.CRIT`。
  - 完全回避：显示 “Lucky”，`TYPE.LUCKY`。
  - Endure：不产生硬直。
  - 其他：自己受到的伤害用单独颜色（`ENEMY`）；SP 伤害和治疗的区分。
  - 现状：`CombatText.Kind` 只有 damage、miss、combo、recovery。
  - 参考：`Renderer/Effects/Damage.js`
- [ ] **P2** 伤害皮肤 `damageSkin` 和伤害动效 `damageMotion`（图形设置项）。
- [ ] **P1** 攻击失败
  - `ZC_ATTACK_FAILURE_FOR_DISTANCE`：距离不够时自动靠近目标。
  - `ZC_ACTION_FAILURE`：显示提示。
  - 参考：`Main.js#onPlayerTooFarToAttack/onActionFailure`
- [ ] **P1** 攻击模式
  - 需要：`/noctrl`（单击后持续攻击）、`/noshift`、`attackTargetMode`，以及锁定目标的准星。
  - 需要：`CZ_CANCEL_LOCKON`。
  - 参考：`Controls/MapControl.js`、`Renderer/Effects/LockOnTarget.js`、`Preferences/Controls.js`
- [ ] **P2** 自动跟随：移动到目标附近的空格子。
  - 参考：`MapControl.js#onAutoFollow`
- [ ] **P2** 怪物普攻特效。
  - 参考：`DB/Monsters/AttackEffectTable.js`

---

## 8. 技能系统

### 8.1 使用与交互

- [ ] **P0** 技能目标选择
  - 单体技能：点击选中敌方或友方目标，可以对自己、队友和怪物施放。
  - 地面技能：显示地面光标（`MagicTarget`）。
  - 施放时可以用滚轮或手势选择技能等级；右键或返回键取消。
  - 移动端需要一套等价的交互。
  - 参考：`UI/Components/SkillTargetSelection/`、`Renderer/Effects/MagicTarget.js`、`MapControl.js`
- [ ] **P1** 技能冷却和公共延迟
  - 需要：`ZC_SKILL_POSTDELAY`，在快捷栏和技能列表上显示冷却遮罩。
  - 参考：`Skill.js#onSetSkillDelay`
- [ ] **P1** 技能树
  - 需要：按职业布局的技能树（取代当前的平铺列表）、前置技能需求提示、独立的技能描述窗口。
  - 参考：`DB/Skills/SkillTreeView.js`、`UI/Components/SkillList/SkillRequirements.js`、`SkillDescription/`
- [ ] **P1** 技能施放动作：按技能选择动作。
  - 现状：一律用 `.skill` 或 `.attack1`。
  - 参考：`DB/Skills/SkillAction.js`
- [ ] **P2** 技能消息 `ZC_MSG_SKILL`，以及 `ZC_NOTIFY_EFFECT3`（带数值的特效）。
- [ ] **P2** 施法条和施法魔法阵的隐藏规则（`hideCastBar` / `hideCastAura`）。

### 8.2 技能地面单元

- [ ] **P1** 技能单元
  - 需要：`ZC_SKILL_ENTRY(1–5)` 和 `ZC_SKILL_DISAPPEAR`。
  - 包括：火墙、安全之墙、Pneuma、暴风雪、陷阱类、传送之阵门、Land Protector、诗人和舞娘的合奏、冰墙（RSM）、Quagmire、蜘蛛网等。
  - 需要：按 unit_id 映射到特效，处理可见性（陷阱对敌方隐藏）。
  - 参考：`DB/Skills/SkillUnit.js`、`SkillUnitConst.js`、`Renderer/EffectManager.js`（unit 分支）、`Effects/Songs.js`、`Tiles.js`、`FlatColorTile.js`、`PropertyGround.js`、`LPEffect.js`、`SpiderWeb.js`

### 8.3 状态图标

- [ ] **P1** 状态图标栏
  - 需要：`ZC_MSG_STATE_CHANGE(1–5)`。显示 EFST 图标、剩余时间，悬停或长按显示状态说明。
  - 状态同时要驱动实体特效（`addStateEffect`）和屏幕效果（中毒、黑暗、幻觉）。
  - `RagnarokLocalization.StatusInfoTable` 已存在但还没用上。
  - 参考：`UI/Components/StatusIcons/`、`DB/Status/StatusInfo.js`、`StatusConst.js`、`Entity.js#onEntityStatusChange`

### 8.4 职业专属交互窗口

- [ ] **P2** 自动咏唱（Hindsight）选择：`ZC_AUTOSPELLLIST(2)` / `CZ_SELECTAUTOSPELL`。
- [ ] **P2** 抄袭 / 影子自动施法选择：`ZC_SKILL_SELECT_REQUEST` / `CZ_SKILL_SELECT_RESPONSE`。
- [ ] **P2** 圣骑士奉献的连线显示：`ZC_DEVOTIONLIST`。
- [ ] **P2** 记录传送点
  - 需要：`/memo`，发送 `CZ_REMEMBER_WARPPOINT`，处理 `ZC_ACK_REMEMBER_WARPPOINT`。
  - 现状：传送之阵的地点列表已经有了。
- [ ] **P2** 制作箭矢：`ZC_MAKINGARROW_LIST` / `CZ_REQ_MAKINGARROW`。
  - 参考：`UI/Components/MakeArrowSelection/`
- [ ] **P2** 修理武器：`ZC_REPAIRITEMLIST(2)` / `CZ_REQ_ITEMREPAIR`。
- [ ] **P2** 铁匠精炼武器：`ZC_NOTIFY_WEAPONITEMLIST` / `CZ_REQ_WEAPONREFINE`。
  - 参考：`UI/Components/RefineWeaponSelection/`
- [ ] **P2** 鉴定（放大镜）：`ZC_ITEMIDENTIFY_LIST` / `CZ_REQ_ITEMIDENTIFY` / `ZC_ACK_ITEMIDENTIFY`。
- [ ] **P2** 锻造和制药
  - 需要：`ZC_MAKABLEITEMLIST` / `CZ_REQMAKINGITEM`，以及 `ZC_MAKINGITEM_LIST` / `CZ_REQ_MAKINGITEM`。
  - 参考：`UI/Components/MakeItemSelection/`
- [ ] **P2** 通用物品列表选择：`ZC_ITEMLISTWIN_OPEN` / `CZ_ITEMLISTWIN_RES(2)`。
  - 参考：`MakeItemSelection/ItemListWindowSelection.js`
- [ ] **P2** 大魔导士（Warlock）的读书技能。
  - 参考：`UI/Components/MakeReadBook/`
- [ ] **P2** 怪物情报（Sense）：`ZC_MONSTER_INFO`。
  - 参考：`UI/Components/Sense/`
- [ ] **P2** 拳圣的感知和怨恨：`ZC_STARSKILL`；以及跆拳道任务。
  - 参考：`Skill.js#onTaekwonMission`
- [ ] **P3** 超级初心者咒语：聊天行数满足条件时发送 `CZ_CHOPOKGI`。
  - 参考：`Engine/MapEngine.js#onRequestTalk`
- [ ] **P3** `ZC_SKILL_SCALE`（技能作用范围显示）。

---

## 9. 特效系统

- [ ] **P1** 移植 `EffectTable`
  - 进度：46 个，roBrowser 约 615 个 EffectID。
  - 参考：`DB/Effects/EffectTable.js`
- [ ] **P1** 移植 `SkillEffectTable`
  - 进度：23 个，roBrowser 约 1013 个技能。
  - 参考：`DB/Skills/SkillEffect.js`
- [ ] **P1** `SkillEffectDefinition` 缺的触发点
  - 缺：`effectIdOnCaster`、`groundEffectId`、`releaseEffectId`、`successEffectIdOnCaster`、`hideCastBar`、`hideCastAura`。
  - 现状：只有 beginCast、beforeHit、hit、effects、success。
- [ ] **P1** 补齐 `NotifyEffect` 映射
  - 现状：`onSpecialEffect` 只处理了 Base / Job 升级。
  - 需要：精炼成功 / 失败、合成、卡片、死亡等 `ZC_NOTIFY_EFFECT` 类型。
  - 参考：`Engine/MapEngine/Skill.js#onSpecialEffect`
- [ ] **P1** 使用物品的特效
  - 现状：`ZC_USE_ITEM_ACK` 只更新背包。
  - 需要：在使用者身上播放药水等物品的特效，其他玩家使用时也要播放。
  - 参考：`DB/Items/ItemEffect.js`、`Item.js#onItemUseAnswer`
- [ ] **P1** 补齐特效类型
  - `RSM` / `RSM2`：3D 模型特效。参考 `Renderer/Effects/RsmEffect.js`。
  - `FUNC`：程序化特效，见下一条。
  - `TRAIL`：拖尾。
  - `WATERFALL`：瀑布和粒子。
  - `QuadHorn`
- [ ] **P2** 程序化特效（`Renderer/Effects/*.js`）
  - 施法和目标：MagicRing、MagicTarget、LockOnTarget。
  - 光环：GroundAura、SwirlingAura、Level99Bubble。
  - 地面：PropertyGround、LPEffect、Songs、Tiles / FlatColorTile、SpiderWeb。
  - 球体：SpiritSphere、WarlockSphere。
  - 其他：MagnumBreak、QuadHorn、PoisonEffect、Waterfall。
- [ ] **P2** 天气特效
  - 包括：SnowWeather、RainWeather、SakuraWeatherEffect、PokJukWeatherEffect（烟花）、CloudWeatherEffect（两种云）、落叶、天空（`Sky.js`）。
- [ ] **P2** 屏幕效果
  - 包括：黑暗暗角（Blind）、中毒屏幕、幻觉扭曲、夜晚。
  - 震屏：Camera quake，比如 `quake_magnum`。
  - 参考：`Renderer/ScreenEffectManager.js`、`Renderer/Camera.js#quake`
- [ ] **P3** 特效开关：`/effect`（关闭非基础特效）、`/mineffect`（精简特效）、`/miss`（Miss 动画开关）。

---

## 10. 地图渲染与画面

- [ ] **P2** 遮挡淡化：相机和玩家之间的模型自动半透明。
  - 参考：`Renderer/Map/OccluderFade.js`
- [ ] **P2** 天空盒和云层。
  - 参考：`Renderer/Effects/Sky.js`
- [ ] **P2** 夜晚模式（mapflag night / `setNight`）。
- [ ] **P2** macOS 下的鼠标光标类型和悬停高亮
  - 光标类型：攻击、对话、拾取、传送、技能、不可行走。
  - 参考：`UI/CursorManager.js`、`EntityControl.js#onFocus`
- [ ] **P3** 后处理：Bloom、FXAA、CAS 锐化、卡通描边、Vibrance、高斯模糊。
  - 参考：`Renderer/Effects/PostProcess.js`、`Effects/Shaders/*`
- [ ] **P3** 画质选项
  - 包括：`pixelPerfectSprites`、`viewArea`（可视范围）、`fpslimit`、`performanceMode`、`/lightmap`、`/fog`、`/smoothlight`（光照贴图色阶）。
  - 参考：`Preferences/Graphics.js`、`Preferences/Map.js`、`UI/Components/GraphicsOption/`
- [ ] **P3** 截图：Print Screen 保存截图，并叠加时间和地图信息。
  - 参考：`Controls/ScreenShot.js`
- [ ] **P3** FPS 显示。
  - 参考：`UI/Components/FPS/`

---

## 11. 相机

- [ ] **P2** 室内地图用单独的缩放上下限（`MAX_ZOOM_INDOOR`），室内室外各自记住缩放值。
  - 参考：`Renderer/Camera.js`、`DB/Map/MapTable.js`（室内标记）
- [ ] **P2** 镜头平滑开关 `/camera`，双击重置视角和缩放。
- [ ] **P3** 第一人称视角（`FirstPersonCamera`）。
- [ ] **P3** 镜头偏好持久化。
  - 参考：`Preferences/Camera.js`

---

## 12. 音频

- [ ] **P1** 音量和开关
  - 需要：BGM 和音效各自可以开关、调音量，并持久化；支持 `/bgm` 和 `/sound`。
  - 现状：选项菜单里的“Sound”按钮是禁用的。
  - 参考：`Preferences/Audio.js`、`UI/Components/SoundOption/`、`Audio/BGM.js`、`Audio/SoundManager.js`
- [ ] **P2** NPC 触发的音效和 BGM：`ZC_SOUND`、`ZC_PLAY_NPC_BGM`。
  - 参考：`Engine/MapEngine/NPC.js#onSound/onBGM`

---

## 13. 物品、背包与装备

- [ ] **P1** 查看他人装备
  - 需要：`CZ_EQUIPWIN_MICROSCOPE` 和 `ZC_EQUIPWIN_MICROSCOPE(_V2–V7)`。
  - 需要：通过 `CZ_CONFIG` 设置是否公开自己的装备。
  - 参考：`UI/Components/PlayerViewEquip/`
- [ ] **P1** 完整的物品信息窗口
  - 卡槽列表，点击卡片查看卡片信息和卡片插画。
  - 随机选项（`ItemRandomOptionNameTable` 已存在）。
  - 精炼等级和附魔等级（grade）。
  - 未鉴定物品的显示。
  - 物品对比和头饰预览。
  - 参考：`UI/Components/ItemInfo/`、`ItemCompare/`、`CardIllustration/`、`ItemPreview/`
- [ ] **P1** 插卡
  - 需要：`CZ_REQ_ITEMCOMPOSITION_LIST` → `ZC_ITEMCOMPOSITION_LIST` → `CZ_REQ_ITEMCOMPOSITION` → `ZC_ACK_ITEMCOMPOSITION`。
  - 参考：`Item.js#onUseCard/onItemCompositionList`
- [ ] **P1** 装备窗口页签
  - 需要：时装页、影子装备页，每个格子显示精炼值；装备窗口里的属性总览。
  - 参考：`UI/Components/Equipment/`
- [ ] **P1** 背包容量
  - 现状：`ZC_EXTEND_BODYITEM_SIZE` 是空处理。
  - 需要：处理背包扩展，包括 `CZ_REQ_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE`、`ZC_ACK_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE`、`CZ_REQ_EXTEND_BODYITEM_SIZE`、`ZC_ACK_EXTEND_BODYITEM_SIZE`、`CZ_CLOSE_MSGBOX_EXTEND_BODYITEM_SIZE`。
  - 参考：`UI/Components/Inventory/InventoryCommon.js`
- [ ] **P2** 背包收藏页签：`ZC_ITEM_FAVORITE` / `CZ_INVENTORY_TAB`。
- [ ] **P2** 负重惩罚：`ZC_RECOVER_PENALTY_OVERWEIGHT`，显示 50% 和 90% 负重状态。
- [ ] **P2** 装备切换
  - 需要：`ZC_SEND_SWAP_EQUIPITEM_INFO`、`CZ_REQ_WEAR_SWITCHEQUIP_ADD/REMOVE`、`ZC_REQ_WEAR_SWITCHEQUIP_ADD/REMOVE_RESULT`、`CZ_REQ_FULLSWITCH`。
  - 参考：`UI/Components/SwitchEquip/`
- [ ] **P2** 物品交互方式
  - 拖到地面丢弃（有些物品需要输入数量），装备窗口打开时禁止丢弃，支持物品丢弃锁。
  - 拖到交易、摊位、手推车窗口里转移。
  - 参考：`MapControl.js#onDrop`、`UI/Components/Inventory/InventoryItemTransfer.js`
- [ ] **P3** 获得物品时的弹出提示。
  - 参考：`UI/Components/ItemObtain/`
- [ ] **P3** 物品随机选项修改：`ZC_CHANGE_ITEM_OPTION`。

---

## 14. 仓库与手推车

- [ ] **P1** 手推车
  - 现状：`ZC_NOTIFY_CARTITEM_COUNTINFO` 是空处理，`invType = 1` 的物品列表也被忽略。
  - 需要：`ZC_ADD_ITEM_TO_CART(1–4)`、`ZC_DELETE_ITEM_FROM_CART`、`ZC_ACK_ADDITEM_TO_CART`。
  - 需要：`CZ_MOVE_ITEM_FROM_BODY_TO_CART`、`CZ_MOVE_ITEM_FROM_CART_TO_BODY`、`CZ_MOVE_ITEM_FROM_CART_TO_STORE`、`CZ_MOVE_ITEM_FROM_STORE_TO_CART`。
  - 需要：手推车窗口、更换手推车样式、手推车装饰。
  - 参考：`Item.js#onCartSetList/onCartSetInfo/...`、`UI/Components/CartItems/`、`ChangeCart/`、`CartDecoration/`
- [ ] **P1** 公会仓库
  - 现状：`invType = 3` 被忽略。它和个人仓库复用同一套 store 包，但窗口需要标题区分。
- [ ] **P3** 旧版仓库列表包（`ZC_STORE_NORMAL/EQUIPMENT_ITEMLIST(1–5)`），只在运行时多版本时才需要。

---

## 15. 聊天与社交

### 15.1 聊天框

- [ ] **P0** 发送组队、公会、氏族消息
  - 需要：`CZ_REQUEST_CHAT_PARTY`、`CZ_GUILD_CHAT`、`CZ_CLAN_CHAT`。
  - 现状：`GameSession.sendMessage` 里这几个分支被注释掉了。
  - 输入方式：前缀 `%`、`$`、`/cl`，以及 Ctrl / Alt 切换频道。
  - 参考：`Engine/MapEngine.js#onRequestTalk`
- [ ] **P0** 私聊
  - 需要：发送 `CZ_WHISPER`，处理 `ZC_ACK_WHISPER(2)`（对方不在线、被屏蔽等）。
  - 需要：私聊对象输入栏、最近私聊对象列表、独立的私聊窗口。
  - 参考：`Engine/MapEngine/PrivateMessage.js`、`UI/Components/WhisperBox/`
- [ ] **P1** 聊天框能力
  - 消息类型着色：SELF、PUBLIC、PRIVATE、PARTY、GUILD、ANNOUNCE、ERROR、INFO、BLUE、ADMIN、MAIL、CLAN。
  - 22 类过滤（物品、装备、状态、战斗、经验、任务、战场等）。
  - 多页签和页签设置、输入历史、字体缩放、战斗模式开关。
  - 参考：`UI/Components/ChatBox/`、`ChatBoxSettings/`
- [ ] **P1** 公告
  - 需要：`ZC_BROADCAST` / `ZC_BROADCAST2`（当前为空处理），显示在顶部公告栏并写入聊天框。
  - 参考：`Main.js#onGlobalAnnounce`、`UI/Components/Announce/`
- [ ] **P1** 系统消息：`ZC_MSG`（按 msgstringtable 编号）、`ZC_MSG_COLOR`。
  - 参考：`Main.js#onMessage`

### 15.2 组队

- [ ] **P1** 组队系统
  - 创建：`CZ_MAKE_GROUP(2)` → `ZC_ACK_MAKE_GROUP`，也可以用 `/organize`。
  - 邀请：新版按名字发 `CZ_PARTY_JOIN_REQ`，结果为 `ZC_PARTY_JOIN_REQ_ACK`；旧版按 AID 发 `CZ_REQ_JOIN_GROUP`，结果为 `ZC_ACK_REQ_JOIN_GROUP`。也可以用 `/invite`。
  - 收到邀请：`ZC_PARTY_JOIN_REQ` → 回复 `CZ_PARTY_JOIN_REQ_ACK`。
  - 成员：`ZC_GROUP_LIST(1–3)`、`ZC_ADD_MEMBER_TO_GROUP(1–4)`、`ZC_DELETE_MEMBER_FROM_GROUP`、`ZC_GROUP_ISALIVE`。
  - 离队和踢人：`CZ_REQ_LEAVE_GROUP`（`/leave`）、`CZ_REQ_EXPEL_GROUP_MEMBER`。
  - 转让队长：`CZ_CHANGE_GROUP_MASTER`。
  - 经验和物品分配：`ZC_GROUPINFO_CHANGE`、`ZC_REQ_GROUPINFO_CHANGE_V2`、`CZ_GROUPINFO_CHANGE_V2`。
  - 拒绝邀请设置：`ZC_PARTY_CONFIG`（当前为空处理）。
  - 队友 HP：`ZC_NOTIFY_HP_TO_GROUPM(_R2)`。
  - 队友在小地图上的位置：`ZC_NOTIFY_POSITION_TO_GROUPM`。
  - 参考：`Engine/MapEngine/Group.js`、`UI/Components/PartyFriends/`

### 15.3 好友

- [ ] **P1** 好友系统
  - 列表：`ZC_FRIENDS_LIST`（当前为空处理）、`ZC_FRIENDS_STATE`（上下线）。
  - 添加：`CZ_ADD_FRIENDS` → `ZC_REQ_ADD_FRIENDS` → `CZ_ACK_REQ_ADD_FRIENDS` → `ZC_ADD_FRIENDS_LIST`。
  - 删除：`CZ_DELETE_FRIENDS` / `ZC_DELETE_FRIENDS`。
  - `/hi` 向所有好友打招呼。
  - 参考：`Engine/MapEngine/Friends.js`

### 15.4 公会

- [ ] **P2** 公会系统
  - 创建和解散
    - 创建：`CZ_REQ_MAKE_GUILD` → `ZC_RESULT_MAKE_GUILD`，也可以用 `/guild`，需要华丽金属。
    - 解散：`CZ_REQ_DISORGANIZE_GUILD` → `ZC_ACK_DISORGANIZE_GUILD_RESULT`，也可以用 `/breakguild`。
  - 基本信息
    - `ZC_GUILD_INFO(1–4)`、`ZC_MYGUILD_BASIC_INFO`、`ZC_UPDATE_GDID(2)`、`CZ_REQ_GUILD_MENUINTERFACE` / `ZC_ACK_GUILD_MENUINTERFACE`、`CZ_REQ_GUILD_MENU`。
  - 成员
    - `ZC_MEMBERMGR_INFO(1–3)`、`ZC_ACK_GUILD_MEMBER_INFO`、`ZC_UPDATE_CHARSTAT(2)`、`CZ_REQ_OPEN_MEMBER_INFO`、`CZ_REQ_CHANGE_MEMBERPOS` / `ZC_ACK_REQ_CHANGE_MEMBERS`。
  - 职位
    - `ZC_POSITION_INFO`、`ZC_POSITION_ID_NAME_INFO`、`CZ_REG_CHANGE_GUILD_POSITIONINFO` / `ZC_ACK_CHANGE_GUILD_POSITIONINFO`。
  - 邀请
    - 发起：`CZ_REQ_JOIN_GUILD(2)`；收到邀请：`ZC_REQ_JOIN_GUILD` → `CZ_JOIN_GUILD`；结果：`ZC_ACK_REQ_JOIN_GUILD`。
    - 也可以用 `/guildinvite`。
  - 退会和开除
    - `CZ_REQ_LEAVE_GUILD` / `ZC_ACK_LEAVE_GUILD`、`CZ_REQ_BAN_GUILD` / `ZC_ACK_BAN_GUILD(_SSO)`，开除记录 `ZC_BAN_LIST`。
  - 公告：`CZ_GUILD_NOTICE` / `ZC_GUILD_NOTICE`。
  - 公会技能：`ZC_GUILD_SKILLINFO`，复用 `CZ_UPGRADE_SKILLLEVEL` 升级。
  - 同盟和敌对
    - 同盟：`CZ_REQ_ALLY_GUILD` → `ZC_REQ_ALLY_GUILD` → `CZ_ALLY_GUILD` → `ZC_ACK_REQ_ALLY_GUILD`。
    - 敌对：`CZ_REQ_HOSTILE_GUILD` / `ZC_ACK_REQ_HOSTILE_GUILD`。
    - 关系列表：`ZC_ADD_RELATED_GUILD` / `ZC_DELETE_RELATED_GUILD` / `CZ_REQ_DELETE_RELATED_GUILD`。
  - 徽章：`CZ_REGISTER_GUILD_EMBLEM_IMG`、`CZ_REQ_GUILD_EMBLEM_IMG`、`ZC_GUILD_EMBLEM_IMG`。
  - 其他
    - 城堡信息 `ZC_GUILD_AGIT_INFO`。
    - 小地图上显示公会成员位置 `ZC_NOTIFY_POSITION_TO_GUILDM`。
    - 公会聊天，见 §15.1。
  - 参考：`Engine/MapEngine/Guild.js`、`UI/Components/Guild/`、`GuildCompanion/`

### 15.5 氏族

- [ ] **P2** 氏族信息
  - 需要：`ZC_CLANINFO`、`ZC_NOTIFY_CLAN_CONNECTINFO`、`ZC_ACK_CLAN_LEAVE`，以及氏族窗口。
  - 参考：`Engine/MapEngine/Clan.js`、`UI/Components/Clan/`

### 15.6 聊天室

- [ ] **P1** 聊天室
  - 创建：`CZ_CREATE_CHATROOM` → `ZC_ACK_CREATE_CHATROOM`，也可以用 `/chat`。
  - 进入：`CZ_REQ_ENTER_ROOM` → `ZC_ENTER_ROOM` / `ZC_REFUSE_ENTER_ROOM`，带密码。
  - 成员：`ZC_MEMBER_NEWENTRY`、`ZC_MEMBER_EXIT`。
  - 修改设置：`CZ_CHANGE_CHATROOM` / `ZC_CHANGE_CHATROOM`。
  - 转让房主：`CZ_REQ_ROLE_CHANGE` / `ZC_ROLE_CHANGE`。
  - 踢人：`CZ_REQ_EXPEL_MEMBER`。
  - 离开：`CZ_EXIT_ROOM`，也可以用 `/q`。
  - 头顶招牌，见 §6.4。
  - 参考：`Engine/MapEngine/ChatRoom.js`、`UI/Components/ChatRoom/`、`ChatRoomCreate/`

### 15.7 玩家上下文菜单

- [ ] **P1** 在其他玩家上右键或长按弹出菜单
  - 查看装备、交易、邀请入队、邀请入公会、结盟、敌对、1:1 私聊、加好友。
  - 参考：`Controls/EntityControl.js`（`TYPE_PC` 分支）、`UI/Components/ContextMenu/`

---

## 16. NPC 交互

- [ ] **P1** NPC 立绘：`ZC_SHOW_IMAGE(2)`（当前为空处理），需要支持立绘位置。
  - 参考：`NPC.js#onCutin`
- [ ] **P1** 小地图标记：`ZC_COMPASS`（当前为空处理），支持颜色、闪烁和移除。
  - 参考：`NPC.js#onMinimapMarker`、`MiniMapCommon.js#addNpcMark`
- [ ] **P1** 进度条：`ZC_PROGRESS` / `ZC_PROGRESS_CANCEL` / `CZ_PROGRESS`。
- [ ] **P1** 对话框标签解析
  - 需要：`<NAVI>…<INFO>…</INFO></NAVI>`（点击后导航）、`<ITEM>` / `<ITEMLINK>`（点击后显示物品信息）、`<URL>`。
  - 现状：只处理了颜色码。
  - 参考：`UI/Components/NpcBox/NpcBox.js#processNAVITags`
- [ ] **P1** `ZC_CLOSE_SCRIPT`：服务端主动关闭对话框。
- [ ] **P2** NPC 市场
  - 需要：`ZC_NPC_MARKET_OPEN(2)`、`CZ_NPC_MARKET_PURCHASE`、`ZC_NPC_MARKET_PURCHASE_RESULT(2)`、`CZ_NPC_MARKET_CLOSE`。
  - 参考：`Engine/MapEngine/Store.js`、`UI/Components/NpcStore/`
- [ ] **P2** 以物易物
  - 需要：`ZC_NPC_BARTER_MARKET_ITEMINFO`、`ZC_NPC_EXPANDED_BARTER_MARKET_ITEMINFO`，以及对应的 `CZ_*_PURCHASE` 和 `CZ_*_CLOSE`。
- [ ] **P2** 点数商店
  - 需要：`CZ_PC_CASH_POINT_ITEMLIST` → `ZC_PC_CASH_POINT_ITEMLIST`、`CZ_PC_BUY_CASH_POINT_ITEM`、`ZC_PC_CASH_POINT_UPDATE`。
- [ ] **P3** 动态 NPC：`CZ_DYNAMICNPC_CREATE_REQUEST` / `ZC_DYNAMICNPC_CREATE_RESULT`。

---

## 17. 交易、摆摊与收购

- [ ] **P1** 玩家交易
  - 发起：`CZ_REQ_EXCHANGE_ITEM` → `ZC_REQ_EXCHANGE_ITEM(2)` → `CZ_ACK_EXCHANGE_ITEM` → `ZC_ACK_EXCHANGE_ITEM(2)`。
  - 加入物品和 Zeny：`CZ_ADD_EXCHANGE_ITEM` → `ZC_ACK_ADD_EXCHANGE_ITEM`，对方加入时收到 `ZC_ADD_EXCHANGE_ITEM(1–5)`。
  - 锁定：`CZ_CONCLUDE_EXCHANGE_ITEM` / `ZC_CONCLUDE_EXCHANGE_ITEM`。
  - 确认：`CZ_EXEC_EXCHANGE_ITEM` / `ZC_EXEC_EXCHANGE_ITEM`。
  - 取消：`CZ_CANCEL_EXCHANGE_ITEM` / `ZC_CANCEL_EXCHANGE_ITEM`。
  - 参考：`Engine/MapEngine/Trade.js`、`UI/Components/Trade/`
- [ ] **P1** 摆摊：开店
  - 需要：`ZC_OPENSTORE`（技能触发）→ `CZ_REQ_OPENSTORE2` → `ZC_ACK_OPENSTORE2`。
  - 自己摊位的物品列表：`ZC_PC_PURCHASE_MYITEMLIST(2)`。
  - 售出通知：`ZC_DELETEITEM_FROM_MCSTORE(2)`。
  - 收摊：`CZ_REQ_CLOSESTORE`。
  - 窗口：摆摊窗口、销售报告。
  - 参考：`Engine/MapEngine/Store.js`、`UI/Components/Vending/`、`VendingReport/`
- [ ] **P1** 摆摊：购买
  - 需要：`CZ_REQ_BUY_FROMMC` → `ZC_PC_PURCHASE_ITEMLIST_FROMMC(1–3)` → `CZ_PC_PURCHASE_ITEMLIST_FROMMC(2)` → `ZC_PC_PURCHASE_RESULT_FROMMC`。
  - 参考：`UI/Components/VendingShop/`
- [ ] **P2** 收购店
  - 需要：`ZC_OPEN_BUYING_STORE`、`CZ_REQ_OPEN_BUYING_STORE`、`ZC_MYITEMLIST_BUYING_STORE`、`CZ_REQ_CLICK_TO_BUYING_STORE`、`ZC_ACK_ITEMLIST_BUYING_STORE`、`CZ_REQ_TRADE_BUYING_STORE`、`ZC_FAILED_OPEN_BUYING_STORE_TO_BUYER`、`ZC_FAILED_TRADE_BUYING_STORE_TO_SELLER`、`CZ_REQ_CLOSE_BUYING_STORE`。

---

## 18. 宠物、生命体与佣兵

- [ ] **P2** 宠物
  - 捕捉：`ZC_START_CAPTURE` → `CZ_TRYCAPTURE_MONSTER` → `ZC_TRYCAPTURE_MONSTER`，捕捉时显示老虎机动画。
  - 孵化：`ZC_PETEGG_LIST` → `CZ_SELECT_PETEGG`。
  - 属性和状态：`ZC_PROPERTY_PET`、`ZC_CHANGESTATE_PET`。
  - 喂食：`ZC_FEED_PET`。
  - 动作：`ZC_PET_ACT` / `CZ_PET_ACT`。
  - 指令：`CZ_COMMAND_PET`，包括喂食、表演、回蛋、卸下饰品。
  - 改名：`CZ_RENAME_PET`。
  - 进化：`CZ_PET_EVOLUTION` / `ZC_PET_EVOLUTION_RESULT`。
  - 宠物的表情和台词。
  - 宠物信息窗口，以及宠物的上下文菜单。
  - 参考：`Engine/MapEngine/Pet.js`、`DB/Pets/*`、`UI/Components/PetInformations/`、`PetEvolution/`、`SlotMachine/`
- [ ] **P2** 生命体
  - 属性：`ZC_PROPERTY_HOMUN(1–5)`、`ZC_HO_PAR_CHANGE(2)`、`ZC_CHANGESTATE_MER`。
  - 喂食：`ZC_FEED_MER`。
  - 技能：`ZC_HOSKILLINFO_LIST/UPDATE`。
  - 指令：`CZ_COMMAND_MER`（喂食、安息等）、`CZ_RENAME_MER`。
  - 移动和攻击：`CZ_REQUEST_MOVENPC`、`CZ_REQUEST_ACTNPC`、`CZ_REQUEST_MOVETOOWNER`。
  - 窗口：生命体信息、生命体技能列表。
  - 参考：`Engine/MapEngine/Homun.js`、`UI/Components/HomunInformations/`、`SkillListMH/`
- [ ] **P2** 佣兵
  - 需要：`ZC_MER_INIT`、`ZC_MER_PROPERTY`、`ZC_MER_PAR_CHANGE`、`ZC_MER_SKILLINFO_LIST/UPDATE`、`CZ_MER_COMMAND`，以及佣兵信息窗口。
  - 参考：`Engine/MapEngine/Mercenary.js`、`UI/Components/MercenaryInformations/`
- [ ] **P3** 生命体和佣兵的 Lua AI
  - 需要：`/hoai`、`/merai` 切换默认和自定义 AI；在客户端运行 `AI.lua` 并驱动上面的移动和攻击包。
  - roBrowser 用 Wasmoon 实现。本仓库的 `RagnarokScript` 已有 Lua 加载能力，可以复用。
  - 参考：`Core/AIDriver.js`

---

## 19. 任务、成就、声望与签到

- [ ] **P1** 任务
  - 需要：`ZC_ALL_QUEST_LIST(1–4)`、`ZC_ALL_QUEST_MISSION`、`ZC_ADD_QUEST(1–3)`、`ZC_DEL_QUEST`、`ZC_UPDATE_MISSION_HUNT(1–4)`、`ZC_ACTIVE_QUEST` / `CZ_ACTIVE_QUEST`。
  - 需要：任务窗口（进行中 / 已完成）、任务追踪。
  - 参考：`Engine/MapEngine/Quest.js`、`UI/Components/Quest/`
- [ ] **P2** 成就
  - 现状：`ZC_ALL_ACH_LIST` 和 `ZC_ACH_UPDATE` 是空处理。
  - 需要：`CZ_REQ_ACH_REWARD` / `ZC_REQ_ACH_REWARD_ACK`，以及成就窗口。
  - 参考：`Engine/MapEngine/Achievement.js`、`UI/Components/Achievement/`
- [ ] **P3** 声望：`ZC_REPUTE_INFO`（当前为空处理）和声望窗口。
- [ ] **P3** 签到：`CZ_REQ_CHECK_ATTENDANCE`；打开 UI：`ZC_UI_OPEN(_V3)` / `CZ_UI_OPEN`。
  - 参考：`UI/Components/CheckAttendance/`、`Engine/MapEngine/UIOpen.js`
- [ ] **P3** 排行榜
  - 通用排行：`CZ_RANKING` / `ZC_ACK_RANKING(2)`。
  - 职业排行：`/alchemist`、`/blacksmith`、`/taekwon`，对应 `CZ_*_RANK` 和 `ZC_*_RANK`。
  - PK 排行：`ZC_KILLER_RANK`。

---

## 20. 邮件

- [ ] **P2** RODEX 邮件（当前版本 20211103 使用这一套）
  - 未读图标：`ZC_RODEX_ICON`。
  - 打开和关闭邮箱：`CZ_OPEN_RODEXBOX` / `CZ_CLOSE_RODEXBOX`。
  - 邮件列表：`ZC_ACK_RODEX_LIST(1–4)`、`CZ_REQ_NEXT_RODEX`、`CZ_REQ_REFRESH_RODEX`。
  - 读信：`CZ_REQ_READ_RODEX` → `ZC_ACK_READ_RODEX(2)`。
  - 领取物品和 Zeny：`CZ_REQ_ITEM_FROM_RODEX` / `ZC_ACK_ITEM_FROM_RODEX`、`CZ_REQ_ZENY_FROM_RODEX` / `ZC_ACK_ZENY_FROM_RODEX`。
  - 删信：`CZ_REQ_DELETE_RODEX` / `ZC_ACK_DELETE_RODEX`。
  - 写信
    - 打开写信窗口：`CZ_REQ_OPEN_WRITE_RODEX` / `ZC_ACK_OPEN_WRITE_RODEX`。
    - 校验收件人：`CZ_CHECK_RECEIVE_CHARACTER_NAME` / `ZC_CHECK_RECEIVE_CHARACTER_NAME(2)`。
    - 添加和移除附件：`CZ_REQ_ADD_ITEM_RODEX` / `ZC_ACK_ADD_ITEM_RODEX(2)`、`CZ_REQ_REMOVE_RODEX_ITEM` / `ZC_ACK_REMOVE_RODEX_ITEM`。
    - 发送：`CZ_REQ_SEND_RODEX(2)` / `ZC_ACK_SEND_RODEX`。
    - 取消：`CZ_REQ_CANCEL_WRITE_RODEX`。
  - 账号邮件：`CZ_OPEN_ALL_RODEX`、`CZ_UPDATE_ALL_RODEX`、`ZC_ACK_FAILED_ALL_RODEX_LIST`。
  - 参考：`Engine/MapEngine/Rodex.js`、`UI/Components/Rodex/`
- [ ] **P3** 旧版邮件：`ZC_MAIL_*`、`CZ_MAIL_*`、`CZ_REQ_MAIL_RETURN`，只在运行时多版本时才需要。
  - 参考：`Engine/MapEngine/Mail.js`、`UI/Components/Mail/`

---

## 21. 精炼、附魔与改造

- [ ] **P2** 精炼窗口
  - 需要：`ZC_OPEN_REFINING_UI`、`CZ_REFINING_SELECT_ITEM` → `ZC_REFINING_MATERIAL_LIST`、`CZ_REQ_REFINING` → `ZC_ACK_ITEMREFINING`、`ZC_BROADCAST_ITEMREFINING_RESULT`、`CZ_CLOSE_REFINING_UI`。
  - 参考：`UI/Components/Refine/`
- [ ] **P2** 装备等级强化（Grade）
  - 需要：`ZC_GRADE_ENCHANT_MATERIAL_LIST`、`CZ_GRADE_ENCHANT_SELECT_EQUIPMENT`、`CZ_GRADE_ENCHANT_REQ` → `ZC_GRADE_ENCHANT_ACK`、`ZC_GRADE_ENCHANT_BROADCAST_RESULT`、`CZ_GRADE_ENCHANT_CLOSE_UI`。
  - 参考：`UI/Components/EnchantGrade/`
- [ ] **P2** 附魔
  - 需要：`CZ_REQUEST_RANDOM_ENCHANT`、`CZ_REQUEST_PERFECT_ENCHANT`、`CZ_REQUEST_UPGRADE_ENCHANT`、`CZ_REQUEST_RESET_ENCHANT` → `ZC_RESPONSE_ENCHANT`，以及 `CZ_CLOSE_UI_ENCHANT`。
  - 参考：`UI/Components/Enchant/`
- [ ] **P3** Laphine 合成和升级
  - 需要：`ZC_RANDOM_COMBINE_ITEM_UI_OPEN` / `CZ_REQ_RANDOM_COMBINE_ITEM` / `ZC_ACK_RANDOM_COMBINE_ITEM`，以及 `ZC_RANDOM_UPGRADE_ITEM_UI_OPEN` / `CZ_REQ_RANDOM_UPGRADE_ITEM` / `ZC_ACK_RANDOM_UPGRADE_ITEM`。
  - 参考：`UI/Components/LaphineSys/`、`LaphineUpg/`
- [ ] **P3** 物品改造：`ZC_OPEN_REFORM_UI` / `CZ_ITEM_REFORM` / `ZC_ITEM_REFORM_ACK` / `CZ_CLOSE_REFORM_UI`。
  - 参考：`UI/Components/ItemReform/`

---

## 22. 其他系统

- [ ] **P2** 银行
  - 需要：`CZ_REQ_BANK_OPEN` / `ZC_ACK_OPEN_BANKING`、`CZ_REQ_BANKING_CHECK` / `ZC_BANKING_CHECK`、`CZ_REQ_BANKING_DEPOSIT` / `ZC_ACK_BANKING_DEPOSIT`、`CZ_REQ_BANKING_WITHDRAW` / `ZC_ACK_BANKING_WITHDRAW`、`CZ_REQ_BANK_CLOSE` / `ZC_ACK_CLOSE_BANKING`。
  - 参考：`Engine/MapEngine/Bank.js`、`UI/Components/Bank/`
- [ ] **P2** 防外挂验证（玩家作答部分）
  - 需要：`ZC_APPLY_MACRO_DETECTOR(_CAPTCHA)`、`ZC_REQ_ANSWER_MACRO_DETECTOR`、`CZ_ACK_ANSWER_MACRO_DETECTOR`、`ZC_CLOSE_MACRO_DETECTOR`。
  - 服务端开启这一功能时，不作答会被判定为外挂。
  - 参考：`Engine/MapEngine/Captcha.js`、`UI/Components/Captcha/CaptchaAnswer.js`
- [ ] **P3** 防外挂验证（GM 部分）
  - 需要：上传、预览和对玩家施加验证：`CZ_REQ_UPLOAD_MACRO_DETECTOR`、`CZ_UPLOAD_MACRO_DETECTOR_CAPTCHA`、`ZC_ACK_UPLOAD_MACRO_DETECTOR`、`ZC_COMPLETE_UPLOAD_MACRO_DETECTOR_CAPTCHA`、`CZ_REQ_PREVIEW_MACRO_DETECTOR`、`ZC_ACK_PREVIEW_MACRO_DETECTOR`、`ZC_PREVIEW_MACRO_DETECTOR_CAPTCHA`、`CZ_REQ_APPLY_MACRO_DETECTOR`、`ZC_ACK_APPLY_MACRO_DETECTOR`、`CZ_REQ_PLAYER_AID_IN_RANGE`、`ZC_ACK_PLAYER_AID_IN_RANGE`。
  - 命令：`/macro_register`、`/macro_detector`、`/macro_preview`。
- [ ] **P3** 现金商城
  - 需要：`CZ_SE_CASHSHOP_OPEN1/2` → `ZC_SE_CASHSHOP_OPEN(1–3)`、`CZ_SE_PC_BUY_CASHITEM_LIST` → `ZC_SE_PC_BUY_CASHITEM_RESULT`、`CZ_CASH_SHOP_CLOSE`、`ZC_ACK_SCHEDULER_CASHITEM`，以及商城入口图标。
  - 参考：`Engine/MapEngine/CashShop.js`、`UI/Components/CashShop/`、`CashShopIcon/`
- [ ] **P3** 轮盘
  - 需要：`CZ_REQ_OPEN_ROULETTE` / `ZC_ACK_OPEN_ROULETTE`、`CZ_REQ_ROULETTE_INFO` / `ZC_ACK_ROULETTE_INFO`、`CZ_REQ_GENERATE_ROULETTE` / `ZC_ACK_GENERATE_ROULETTE`、`CZ_RECV_ROULETTE_ITEM` / `ZC_RECV_ROULETTE_ITEM`、`CZ_REQ_CLOSE_ROULETTE` / `ZC_ACK_CLOSE_ROULETTE`。
- [ ] **P3** 网咖金币计时：`ZC_GOLDPCCAFE_POINT`。
- [ ] **P3** 在线人数：`/who`，发送 `CZ_REQ_USER_COUNT`，处理 `ZC_USER_COUNT`。
- [ ] **P3** 站立复活：`CZ_STANDING_RESURRECTION`，见 §2。

---

## 23. 地图类 UI

- [ ] **P1** 小地图标记
  - 需要：队友和公会成员的位置点、NPC 标记（`ZC_COMPASS`）、城镇设施图标（`DB/TownInfo.js`）、坐标显示、透明度切换。
  - 参考：`UI/Components/MiniMap/MiniMapCommon.js`
- [ ] **P2** 导航
  - 需要：`/navi 地图 x y`、搜索地图 / NPC / 怪物、跨地图寻路（Web Worker 版的 `MapPathFinder`），与 NPC 对话中的 `<NAVI>` 标签联动。
  - 现状：菜单里的导航按钮处于禁用状态。
  - 参考：`UI/Components/Navigation/`
- [ ] **P2** 进图时的地图名提示。
  - 参考：`UI/Components/MapName/`
- [ ] **P2** `/where`：在聊天框显示当前地图名和坐标。

---

## 24. 控制与输入

- [ ] **P1** 键盘快捷键（macOS 和外接键盘）
  - 快捷栏：F1–F9、1–9、Q–O 等三行（`ShortCutControls` 里的 `EXECUTE0…26`）。
  - 窗口开关
    - Alt 组合：Alt+E 背包、Alt+Q 装备、Alt+S 技能、Alt+V 基本信息、Alt+A 状态、Alt+Z 组队、Alt+H 好友、Alt+G 公会、Alt+U 任务、Alt+J 宠物、Alt+R 生命体、Alt+W 手推车、Alt+C 聊天室、Alt+L 表情、Alt+K 成就、Alt+M 快捷键设置。
    - Ctrl 组合：Ctrl+R 佣兵、Ctrl+B 银行、Ctrl+G 氏族。
  - 宏和表情：Alt+数字执行聊天宏（`EXECUTE_MACRO_*`），Ctrl+数字发送表情（`EXECUTE_FLAG_*`）。两者都可以在快捷键设置窗口里自定义。
  - 攻击模式：Alt+T 切换生命体的攻击模式，Ctrl+T 切换佣兵的攻击模式。
  - 其他：Insert 坐下，F10 调整聊天框高度，Esc 打开选项菜单，Enter 聚焦聊天框。
  - 支持自定义快捷键和持久化，以及快捷键设置窗口。
  - 参考：`Preferences/ShortCutControls.js`、`Controls/KeyEventHandler.js`、`UI/Components/ShortCutOption/`
- [ ] **P2** 战斗模式：聊天框切到战斗模式后，字母键直接触发快捷栏。
  - 参考：`Controls/BattleMode.js`、`ChatBox.processBattleMode`
- [ ] **P2** 鼠标操作（macOS）
  - 按住左键持续朝鼠标方向移动（`walkIntervalProcess`）。
  - 右键拖动旋转镜头，滚轮缩放。
  - Shift + 右键原地转向。
  - 参考：`Controls/MapControl.js`、`Engine/MapEngine.js#onRequestWalk`
- [ ] **P2** 自动吸附：`/snap`（光标吸附目标）、`/itemsnap`（光标吸附物品）、`/window`（窗口互相吸附）。
- [ ] **P2** 游戏手柄
  - 使用 GameController 框架，对齐 roBrowser 基于 Gamepad API 的 JoystickUI。
  - 包括：摇杆移动、按键映射到快捷栏、目标切换、虚拟光标。
  - 参考：`UI/Components/JoystickUI/`、`Preferences/Controls.js`（`joy*`）

---

## 25. 斜杠命令

参考：`Controls/ProcessCommand.js`。当前 `ChatBoxView` 会把输入原样发送。需要先建立命令分发器（带别名），再逐个实现。

- [ ] **P1** 基础命令
  - `/sit`（别名 `/stand`）
  - `/where`
  - `/who`（别名 `/w`）
  - `/memo`
  - `/commands`（别名 `/cmd`、`/h`、`/help`）
  - 属性加点 `/str+ n` 等（包括第四转的 `/pow+` 等）
  - 表情命令：`Emotions.commands`，共 64 种表情，每种有多个别名（含韩文键位别名），比如 `/!`、`/?`、`/ho`、`/lv`、`/swt`、`/$`
- [ ] **P1** 社交命令
  - `/organize`、`/invite`、`/leave`
  - `/guild`、`/guildinvite`、`/breakguild`
  - `/chat`、`/q`
  - `/hi`
  - `/cl`（氏族聊天）
  - `/call`
- [ ] **P2** 表现开关
  - `/effect`、`/mineffect`、`/miss`、`/aura`、`/aura2`、`/showname`
  - `/camera`、`/fog`、`/lightmap`、`/smoothlight`
  - `/bgm`、`/sound`
  - `/noctrl`（`/nc`）、`/noshift`（`/ns`）、`/snap`、`/itemsnap`、`/window`（`/wi`）
- [ ] **P2** 其他
  - `/doridori`、`/bangbang`、`/bingbing`
  - `/navi`
  - `/alchemist`、`/blacksmith`、`/taekwon`
  - `/hoai`、`/merai`
- [ ] **P3** GM 命令
  - 广播：`/b`、`/nb`、`/lb`、`/nlb`（`CZ_BROADCAST` / `CZ_LOCALBROADCAST`）
  - 传送：`/mapmove`（`/mm`，`CZ_MOVETO_MAP`）、`/shift`（`CZ_SHIFT`）
  - 召唤：`/summon`（`CZ_RECALL_GID`）、`/recall`（`CZ_RECALL`）
  - 隐身：`/hide`（`CZ_CHANGE_EFFECTSTATE`）
  - 踢人：`/kill`（`CZ_DISCONNECT_CHARACTER`）、`/killall`（`CZ_DISCONNECT_ALL_CHARACTER`）
  - 生成：`/item`、`/monster`（`CZ_ITEM_CREATE`）
  - 重置：`/resetstate`、`/resetskill`（`CZ_RESET`）
  - 其他：`/remove`（`CZ_REMOVE_AID`）、`/check`（`CZ_REQ_STATUS_GM` / `ZC_ACK_STATUS_GM`）、`/changemaptype`（`/cmt`）
- [ ] **P3** 开发命令 `/weather`（天气调试）。

---

## 26. 设置与偏好持久化

- [ ] **P1** 偏好存储层。对应 roBrowser 的 7 组偏好：
  - Audio：BGM 和音效的开关、音量。
  - Graphics：分辨率、画质、FPS 上限、可视范围、伤害皮肤、后处理。
  - Controls：`noctrl`、`noshift`、`snap`、`itemsnap`、`attackTargetMode`、手柄参数。
  - Map：`fog`、`lightmap`、`smoothlight`、`effect`、`mineffect`、`miss`、`aura`、`showname`。
  - Camera：`smooth`、`zoom`、`indoorZoom`。
  - UI：窗口位置、窗口吸附。
  - ShortCutControls：快捷键映射。
  - 参考：`Preferences/*.js`、`Core/Preferences.js`
- [ ] **P1** 选项菜单里当前禁用的三个入口
  - “Settings”：图形设置窗口。
  - “Sound”：声音设置窗口。
  - “BM/Shortcut Settings”：快捷键设置窗口。
  - 参考：`UI/Components/Escape/`、`GraphicsOption/`、`SoundOption/`、`ShortCutOption/`
- [ ] **P2** 窗口位置和大小持久化，以及窗口吸附。
  - 参考：`UI/UIManager.js`、`Preferences/UI.js`

---

## 27. HUD 与窗口补齐

对照 `MenuView` 中当前禁用的按钮，以及 roBrowser 进图时挂载的组件（`Engine/MapEngine.js#onMapChange`）：

| 菜单按钮 / 组件 | 对应章节 | 优先级 |
| --- | --- | --- |
| 组队（bt_party）+ 好友（PartyFriends） | §15.2、§15.3 | P1 |
| 公会（bt_guild） | §15.4 | P2 |
| 战场（bt_battle） | 战场地图标记与战场计数（roBrowser 在 `MapState.js` 里处理）；战场聊天 roBrowser 未实现 | P3 |
| 任务（bt_quest） | §19 | P1 |
| 导航（bt_navigation） | §23 | P2 |
| 银行（bt_bank） | §22 | P2 |
| 录像（bt_rec） | 附录 C（Replay） | P3 |
| 邮件（bt_mail） | §20 | P2 |
| 成就（bt_achievement） | §19 | P2 |
| 提示（bt_tip） | 小贴士窗口 | P3 |
| 快捷键（bt_keyboard） | §24 | P2 |
| 签到（bt_attendance） | §19 | P3 |
| 冒险者中介所（bt_adventureragency） | 组队招募（roBrowser 未实现） | P3 |
| 声望（bt_repute） | §19 | P3 |
| 状态窗口 4 转属性（POW/STA/WIS/SPL/CON/CRT） | `WinStats` 的 Trait 页签；加点接口已有，UI 未显示 | P2 |
| 状态图标栏 | §8.3 | P1 |
| 表情窗口（Emoticons） | §6.4 | P1 |
| 公告栏（Announce） | §15.1 | P1 |

---

## 附录 A：roBrowserLegacy 订阅、RagnarokGame 未处理的服务端包

本附录按 roBrowser 模块分组。同一语义的多个版本合并书写。只要 RagnarokGame 已处理了同名的任一版本，就不列出。空处理（`case _ as X: break`）按“未处理”计。

- **LoginEngine**：`AC_REFUSE_LOGIN_EX`、`AC_REFUSE_LOGIN_USA`、`AC_LOGIN_TAREN_REFUSE(2)`
- **CharEngine**：`HC_SECOND_PASSWD_LOGIN`、`HC_ACCEPT_ENTER_NEO_UNION_LIST(2)`、`HC_ACCEPT_ENTER_NEO_UNION_HEADER`、`HC_CHARLIST_NOTIFY`、`HC_REFUSE_SELECTCHAR`、`HC_ACCEPT_DELETECHAR`、`HC_REFUSE_DELETECHAR`、`HC_ACCEPT_MAKECHAR_NEO_UNION`（旧版）、`HC_DELETE_CHAR3_CANCEL`（空处理）、`HC_BLOCK_CHARACTER`（空处理）
- **MapEngine**：`ZC_NPCACK_SERVERMOVE(2)`、`ZC_ACCEPT_QUIT`、`ZC_REFUSE_QUIT`、`ZC_NOTIFY_TIME`、`ZC_CONFIG`、`ZC_CONFIG_NOTIFY(1–4)`
- **Main**：`ZC_BROADCAST(2)`、`ZC_MSG`、`ZC_MSG_COLOR`、`ZC_ATTACK_FAILURE_FOR_DISTANCE`、`ZC_ACTION_FAILURE`、`ZC_STATUS_CHANGE_ACK`、`ZC_NOTIFY_CARTITEM_COUNTINFO`、`ZC_UPDATE_MAPINFO`、`ZC_USER_COUNT`、`ZC_PERSONAL_INFORMATION(2)`、`ZC_ACK_STATUS_GM`、`ZC_ACK_RANKING(2)`、`ZC_ALCHEMIST_RANK`、`ZC_BLACKSMITH_RANK`、`ZC_TAEKWON_RANK`、`ZC_KILLER_RANK`
- **MapState**：`ZC_MAPPROPERTY(_R2)`、`ZC_NOTIFY_MAPPROPERTY(2)`、`ZC_NOTIFY_RANKING`
- **Entity**
  - 名字和称号：`ZC_ACK_REQNAME`、`ZC_ACK_REQNAMEALL(1–3)`、`ZC_ACK_CHANGE_TITLE`
  - 头顶表现：`ZC_EMOTION`、`ZC_SHOWSCRIPT`、`ZC_QUEST_NOTIFY_EFFECT`、`ZC_HAT_EFFECT`、`ZC_HP_INFO_TINY`
  - 状态：`ZC_MSG_STATE_CHANGE(1–5)`
  - 移动和动作：`ZC_FASTMOVE`、`ZC_HIGHJUMP`、`ZC_NOTIFY_ACT_POSITION`、`ZC_NOTIFY_ACTENTRY`、`ZC_NOTIFY_SKILL_POSITION`、`ZC_BLADESTOP`
  - 技能单元：`ZC_SKILL_ENTRY(1–5)`、`ZC_SKILL_DISAPPEAR`
  - 招牌：`ZC_ROOM_NEWENTRY`、`ZC_DESTROY_ROOM`、`ZC_STORE_ENTRY`、`ZC_DISAPPEAR_ENTRY`、`ZC_BUYING_STORE_ENTRY`、`ZC_DISAPPEAR_BUYING_STORE_ENTRY`、`ZC_STORE_ASSISTANT_ENTRY(_V2)`、`ZC_STORE_ASSISTANT_DISAPPEAR`
  - 其他：`ZC_NPCSPRITE_CHANGE`、`ZC_MVP`、`ZC_MVP_GETTING_ITEM`、`ZC_BOSS_INFO`
- **Skill**
  - 冷却和提示：`ZC_SKILL_POSTDELAY`、`ZC_MSG_SKILL`、`ZC_NOTIFY_MAPINFO`、`ZC_SKILL_SCALE`
  - 球体：`ZC_SPIRITS(2)`、`ZC_MILLENNIUMSHIELD`
  - 选择窗口：`ZC_AUTOSPELLLIST(2)`、`ZC_SKILL_SELECT_REQUEST`、`ZC_DEVOTIONLIST`
  - 制作和修理：`ZC_MAKINGARROW_LIST`、`ZC_REPAIRITEMLIST(2)`、`ZC_NOTIFY_WEAPONITEMLIST`
  - 鉴定：`ZC_ITEMIDENTIFY_LIST`、`ZC_ACK_ITEMIDENTIFY`
  - 其他：`ZC_ACK_REMEMBER_WARPPOINT`、`ZC_SELECTCART`、`ZC_MONSTER_INFO`、`ZC_STARSKILL`
  - 另外 `ZC_NOTIFY_EFFECT3` 未处理（RagnarokGame 只处理了 `ZC_NOTIFY_EFFECT` 和 `ZC_NOTIFY_EFFECT2`）
- **Item**
  - 手推车：`ZC_NOTIFY_CARTITEM_COUNTINFO`、`ZC_CART_NORMAL_ITEMLIST(3–4)`、`ZC_CART_EQUIPMENT_ITEMLIST(3–5)`、`ZC_ADD_ITEM_TO_CART(1–4)`、`ZC_DELETE_ITEM_FROM_CART`、`ZC_ACK_ADDITEM_TO_CART`
  - 查看装备：`ZC_EQUIPWIN_MICROSCOPE(_V2–V7)`
  - 插卡和精炼结果：`ZC_ITEMCOMPOSITION_LIST`、`ZC_ACK_ITEMCOMPOSITION`、`ZC_ACK_ITEMREFINING`
  - 背包：`ZC_EXTEND_BODYITEM_SIZE`、`ZC_ITEM_FAVORITE`、`ZC_RECOVER_PENALTY_OVERWEIGHT`
  - 制作：`ZC_MAKABLEITEMLIST`、`ZC_MAKINGITEM_LIST`、`ZC_ITEMLISTWIN_OPEN`
  - 装备切换：`ZC_SEND_SWAP_EQUIPITEM_INFO`、`ZC_REQ_WEAR_SWITCHEQUIP_ADD_RESULT`、`ZC_REQ_WEAR_SWITCHEQUIP_REMOVE_RESULT`
  - 分块列表：`ZC_SPLIT_SEND_ITEMLIST_NORMAL`、`ZC_SPLIT_SEND_ITEMLIST_EQUIP(2)`
- **Inventory（UI）**：`ZC_ACK_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE`、`ZC_ACK_EXTEND_BODYITEM_SIZE`
- **Storage**：`ZC_SPLIT_SEND_ITEMLIST_SET`、`ZC_SPLIT_SEND_ITEMLIST_RESULT`；公会仓库（`invType = 3`）被忽略
- **NPC**：`ZC_SHOW_IMAGE(2)`、`ZC_COMPASS`、`ZC_PROGRESS`、`ZC_PROGRESS_CANCEL`、`ZC_CLOSE_SCRIPT`、`ZC_SOUND`、`ZC_PLAY_NPC_BGM`、`ZC_DYNAMICNPC_CREATE_RESULT`
- **Store**
  - 摆摊：`ZC_OPENSTORE`、`ZC_ACK_OPENSTORE2`、`ZC_DELETEITEM_FROM_MCSTORE(2)`、`ZC_PC_PURCHASE_ITEMLIST_FROMMC(1–3)`、`ZC_PC_PURCHASE_RESULT_FROMMC`、`ZC_PC_PURCHASE_MYITEMLIST(2)`
  - 收购店：`ZC_OPEN_BUYING_STORE`、`ZC_MYITEMLIST_BUYING_STORE`、`ZC_ACK_ITEMLIST_BUYING_STORE`、`ZC_FAILED_OPEN_BUYING_STORE_TO_BUYER`、`ZC_FAILED_TRADE_BUYING_STORE_TO_SELLER`
  - NPC 市场和以物易物：`ZC_NPC_MARKET_OPEN2`、`ZC_NPC_MARKET_PURCHASE_RESULT(2)`、`ZC_NPC_BARTER_MARKET_ITEMINFO`、`ZC_NPC_EXPANDED_BARTER_MARKET_ITEMINFO`
  - 点数商店：`ZC_PC_CASH_POINT_ITEMLIST`、`ZC_PC_CASH_POINT_UPDATE`
- **Trade**：`ZC_REQ_EXCHANGE_ITEM(2)`、`ZC_ACK_EXCHANGE_ITEM(2)`、`ZC_ADD_EXCHANGE_ITEM(1–5)`、`ZC_ACK_ADD_EXCHANGE_ITEM`、`ZC_CONCLUDE_EXCHANGE_ITEM`、`ZC_CANCEL_EXCHANGE_ITEM`、`ZC_EXEC_EXCHANGE_ITEM`
- **PrivateMessage**：`ZC_ACK_WHISPER(2)`
- **ChatRoom**：`ZC_ACK_CREATE_CHATROOM`、`ZC_ENTER_ROOM`、`ZC_REFUSE_ENTER_ROOM`、`ZC_MEMBER_NEWENTRY`、`ZC_MEMBER_EXIT`、`ZC_CHANGE_CHATROOM`、`ZC_ROLE_CHANGE`、`ZC_ROOM_NEWENTRY`、`ZC_DESTROY_ROOM`
- **Group**：`ZC_ACK_MAKE_GROUP`、`ZC_PARTY_JOIN_REQ`、`ZC_PARTY_JOIN_REQ_ACK`、`ZC_ACK_REQ_JOIN_GROUP`、`ZC_GROUP_LIST(1–3)`、`ZC_ADD_MEMBER_TO_GROUP(1–4)`、`ZC_DELETE_MEMBER_FROM_GROUP`、`ZC_GROUP_ISALIVE`、`ZC_GROUPINFO_CHANGE`、`ZC_REQ_GROUPINFO_CHANGE_V2`、`ZC_PARTY_CONFIG`、`ZC_NOTIFY_HP_TO_GROUPM(_R2)`、`ZC_NOTIFY_POSITION_TO_GROUPM`
- **Friends**：`ZC_FRIENDS_LIST`、`ZC_FRIENDS_STATE`、`ZC_REQ_ADD_FRIENDS`、`ZC_ADD_FRIENDS_LIST`、`ZC_DELETE_FRIENDS`
- **Guild**
  - 信息：`ZC_GUILD_INFO(1–4)`、`ZC_MYGUILD_BASIC_INFO`、`ZC_UPDATE_GDID(2)`、`ZC_ACK_GUILD_MENUINTERFACE`、`ZC_GUILD_NOTICE`、`ZC_GUILD_SKILLINFO`、`ZC_GUILD_AGIT_INFO`
  - 成员和职位：`ZC_MEMBERMGR_INFO(1–3)`、`ZC_ACK_GUILD_MEMBER_INFO`、`ZC_UPDATE_CHARSTAT(2)`、`ZC_ACK_REQ_CHANGE_MEMBERS`、`ZC_POSITION_INFO`、`ZC_POSITION_ID_NAME_INFO`、`ZC_ACK_CHANGE_GUILD_POSITIONINFO`、`ZC_NOTIFY_POSITION_TO_GUILDM`
  - 创建、邀请、退会、解散：`ZC_RESULT_MAKE_GUILD`、`ZC_REQ_JOIN_GUILD`、`ZC_ACK_REQ_JOIN_GUILD`、`ZC_ACK_LEAVE_GUILD`、`ZC_ACK_BAN_GUILD(_SSO)`、`ZC_BAN_LIST`、`ZC_ACK_DISORGANIZE_GUILD_RESULT`
  - 同盟和敌对：`ZC_REQ_ALLY_GUILD`、`ZC_ACK_REQ_ALLY_GUILD`、`ZC_ACK_REQ_HOSTILE_GUILD`、`ZC_ADD_RELATED_GUILD`、`ZC_DELETE_RELATED_GUILD`
  - 徽章：`ZC_GUILD_EMBLEM_IMG`
- **Clan**：`ZC_CLANINFO`、`ZC_NOTIFY_CLAN_CONNECTINFO`、`ZC_ACK_CLAN_LEAVE`
- **Pet / PetEvolution**：`ZC_START_CAPTURE`、`ZC_TRYCAPTURE_MONSTER`、`ZC_PETEGG_LIST`、`ZC_PROPERTY_PET`、`ZC_CHANGESTATE_PET`、`ZC_FEED_PET`、`ZC_PET_ACT`、`ZC_PET_EVOLUTION_RESULT`
- **Homun**：`ZC_PROPERTY_HOMUN(1–5)`、`ZC_HO_PAR_CHANGE(2)`、`ZC_CHANGESTATE_MER`、`ZC_FEED_MER`、`ZC_HOMUN_ACT`、`ZC_HOSKILLINFO_LIST`、`ZC_HOSKILLINFO_UPDATE`
- **Mercenary**：`ZC_MER_INIT`、`ZC_MER_PROPERTY`、`ZC_MER_PAR_CHANGE`、`ZC_MER_SKILLINFO_LIST`、`ZC_MER_SKILLINFO_UPDATE`
- **Quest**：`ZC_ALL_QUEST_LIST(1–4)`、`ZC_ALL_QUEST_MISSION`、`ZC_ADD_QUEST(1–3)`、`ZC_DEL_QUEST`、`ZC_UPDATE_MISSION_HUNT(1–4)`、`ZC_ACTIVE_QUEST`
- **Achievement**：`ZC_ALL_ACH_LIST`（空处理）、`ZC_ACH_UPDATE`（空处理）、`ZC_REQ_ACH_REWARD_ACK`
- **Reputation**：`ZC_REPUTE_INFO`（空处理）
- **UIOpen**：`ZC_UI_OPEN(_V3)`
- **Rodex**：`ZC_RODEX_ICON`、`ZC_ACK_RODEX_LIST(1–4)`、`ZC_ACK_READ_RODEX(2)`、`ZC_ACK_ITEM_FROM_RODEX`、`ZC_ACK_ZENY_FROM_RODEX`、`ZC_ACK_DELETE_RODEX`、`ZC_ACK_OPEN_WRITE_RODEX`、`ZC_CHECK_RECEIVE_CHARACTER_NAME(2)`、`ZC_ACK_ADD_ITEM_RODEX(2)`、`ZC_ACK_REMOVE_RODEX_ITEM`、`ZC_ACK_SEND_RODEX`、`ZC_ACK_FAILED_ALL_RODEX_LIST`
- **Mail（旧版）**：`ZC_MAIL_WINDOWS`、`ZC_MAIL_REQ_GET_LIST`、`ZC_MAIL_REQ_OPEN`、`ZC_MAIL_REQ_GET_ITEM`、`ZC_MAIL_REQ_SEND`、`ZC_MAIL_RECEIVE`、`ZC_ACK_MAIL_ADD_ITEM`、`ZC_ACK_MAIL_DELETE`、`ZC_ACK_MAIL_RETURN`
- **Refine / EnchantGrade / Enchant / ItemReform / Laphine / ItemInfo**
  - 精炼：`ZC_OPEN_REFINING_UI`、`ZC_REFINING_MATERIAL_LIST`、`ZC_BROADCAST_ITEMREFINING_RESULT`
  - 装备等级强化：`ZC_GRADE_ENCHANT_MATERIAL_LIST`、`ZC_GRADE_ENCHANT_ACK`、`ZC_GRADE_ENCHANT_BROADCAST_RESULT`
  - 附魔：`ZC_RESPONSE_ENCHANT`
  - 改造：`ZC_OPEN_REFORM_UI`、`ZC_ITEM_REFORM_ACK`
  - Laphine：`ZC_RANDOM_COMBINE_ITEM_UI_OPEN`、`ZC_ACK_RANDOM_COMBINE_ITEM`、`ZC_RANDOM_UPGRADE_ITEM_UI_OPEN`、`ZC_ACK_RANDOM_UPGRADE_ITEM`
  - 随机选项：`ZC_CHANGE_ITEM_OPTION`
- **Bank**：`ZC_ACK_OPEN_BANKING`、`ZC_BANKING_CHECK`、`ZC_ACK_BANKING_DEPOSIT`、`ZC_ACK_BANKING_WITHDRAW`、`ZC_ACK_CLOSE_BANKING`
- **CashShop**：`ZC_SE_CASHSHOP_OPEN(1–3)`、`ZC_SE_PC_BUY_CASHITEM_RESULT`、`ZC_ACK_SCHEDULER_CASHITEM`
- **Roulette**：`ZC_ACK_OPEN_ROULETTE`、`ZC_ACK_ROULETTE_INFO`、`ZC_ACK_GENERATE_ROULETTE`、`ZC_RECV_ROULETTE_ITEM`、`ZC_ACK_CLOSE_ROULETTE`
- **Captcha**：`ZC_APPLY_MACRO_DETECTOR(_CAPTCHA)`、`ZC_REQ_ANSWER_MACRO_DETECTOR`、`ZC_CLOSE_MACRO_DETECTOR`、`ZC_ACK_APPLY_MACRO_DETECTOR`、`ZC_ACK_UPLOAD_MACRO_DETECTOR`、`ZC_COMPLETE_UPLOAD_MACRO_DETECTOR_CAPTCHA`、`ZC_ACK_PREVIEW_MACRO_DETECTOR`、`ZC_PREVIEW_MACRO_DETECTOR_CAPTCHA`、`ZC_ACK_PLAYER_AID_IN_RANGE`
- **PCGoldTimer**：`ZC_GOLDPCCAFE_POINT`
- **DBManager**：`ZC_ACK_REQNAME_BYGID(2)`

## 附录 B：roBrowserLegacy 发送、RagnarokGame 未发送的客户端包

RagnarokGame 已能发送 44 种客户端包：`CA_LOGIN`、`CA_CONNECT_INFO_CHANGED`、`CH_ENTER`、`CH_SELECT_CHAR`、`CH_MAKE_CHAR`、`CH_DELETE_CHAR3(_RESERVED)`、`CZ_ENTER`、`CZ_REQUEST_MOVE`、`CZ_REQUEST_ACT`、`CZ_CHANGE_DIRECTION`（未被调用）、`CZ_USE_SKILL(_TOGROUND)`、`CZ_USE_ITEM`、`CZ_REQ_WEAR_EQUIP`、`CZ_REQ_TAKEOFF_EQUIP`、`CZ_ITEM_PICKUP`、`CZ_ITEM_THROW`、`CZ_STATUS_CHANGE`、`CZ_ADVANCED_STATUS_CHANGE`、`CZ_UPGRADE_SKILLLEVEL`、`CZ_SHORTCUT_KEY_CHANGE2`、`CZ_SHORTCUTKEYBAR_ROTATE2`、NPC 对话和商店相关、仓库存取和关闭、`CZ_SELECT_WARPPOINT`、`CZ_RESTART`、`CZ_REQUEST_QUIT`、`CZ_REQUEST_TIME`、`CZ_PING_LIVE`、`CZ_NOTIFY_ACTORINIT`。

roBrowser 发送、RagnarokGame 未发送的包，按功能分组：

- **登录和角色**：`CA_EXE_HASHCHECK`、`CA_LOGIN_HAN`、`CH_CHARLIST_REQ`、`CH_DELETE_CHAR3_CANCEL`、`CH_PINCODE_CHECK`、`CH_PINCODE_FIRST_PIN`、`CH_PINCODE_CHANGE`、`CH_PINCODE_REQUEST`
- **会话**：`CZ_BLOCKING_PLAY_CANCEL`、`CZ_HBT`、`CZ_PING`、`CZ_CONFIG`、`CZ_STANDING_RESURRECTION`
- **实体和名字**：`CZ_REQNAME(2)`、`CZ_REQNAME_BYGID(2)`、`CZ_REQ_EMOTION`、`CZ_DORIDORI`、`CZ_REQ_CHANGE_TITLE`、`CZ_CANCEL_LOCKON`、`CZ_REQ_CARTOFF`、`CZ_SELECTCART`、`CZ_REQ_CHANGECART`
- **聊天**：`CZ_WHISPER`、`CZ_REQUEST_CHAT_PARTY`、`CZ_GUILD_CHAT`、`CZ_CLAN_CHAT`、`CZ_BROADCAST`、`CZ_LOCALBROADCAST`、`CZ_CHOPOKGI`
- **技能**：`CZ_SELECTAUTOSPELL`、`CZ_SKILL_SELECT_RESPONSE`、`CZ_REMEMBER_WARPPOINT`、`CZ_REQ_MAKINGARROW`、`CZ_REQ_ITEMREPAIR`、`CZ_REQ_WEAPONREFINE`、`CZ_REQ_ITEMIDENTIFY`、`CZ_REQMAKINGITEM`、`CZ_REQ_MAKINGITEM`、`CZ_ITEMLISTWIN_RES(2)`
- **物品**
  - 查看装备和插卡：`CZ_EQUIPWIN_MICROSCOPE`、`CZ_REQ_ITEMCOMPOSITION_LIST`、`CZ_REQ_ITEMCOMPOSITION`
  - 背包：`CZ_INVENTORY_TAB`、`CZ_REQ_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE`、`CZ_REQ_EXTEND_BODYITEM_SIZE`、`CZ_CLOSE_MSGBOX_EXTEND_BODYITEM_SIZE`
  - 装备切换：`CZ_REQ_WEAR_SWITCHEQUIP_ADD/REMOVE`、`CZ_REQ_FULLSWITCH`
  - 手推车：`CZ_MOVE_ITEM_FROM_BODY_TO_CART`、`CZ_MOVE_ITEM_FROM_CART_TO_BODY`、`CZ_MOVE_ITEM_FROM_CART_TO_STORE`、`CZ_MOVE_ITEM_FROM_STORE_TO_CART`
- **NPC 和商店**
  - `CZ_PROGRESS`、`CZ_DYNAMICNPC_CREATE_REQUEST`
  - NPC 市场和以物易物：`CZ_NPC_MARKET_PURCHASE/CLOSE`、`CZ_NPC_BARTER_MARKET_PURCHASE/CLOSE`、`CZ_NPC_EXPANDED_BARTER_MARKET_PURCHASE/CLOSE`
  - 点数商店：`CZ_PC_CASH_POINT_ITEMLIST`、`CZ_PC_BUY_CASH_POINT_ITEM`
- **交易和摆摊**
  - 交易：`CZ_REQ_EXCHANGE_ITEM`、`CZ_ACK_EXCHANGE_ITEM`、`CZ_ADD_EXCHANGE_ITEM`、`CZ_CONCLUDE_EXCHANGE_ITEM`、`CZ_EXEC_EXCHANGE_ITEM`、`CZ_CANCEL_EXCHANGE_ITEM`
  - 摆摊：`CZ_REQ_OPENSTORE2`、`CZ_REQ_CLOSESTORE`、`CZ_REQ_BUY_FROMMC`、`CZ_PC_PURCHASE_ITEMLIST_FROMMC(2)`
  - 收购店：`CZ_REQ_OPEN_BUYING_STORE`、`CZ_REQ_CLICK_TO_BUYING_STORE`、`CZ_REQ_TRADE_BUYING_STORE`、`CZ_REQ_CLOSE_BUYING_STORE`
- **聊天室**：`CZ_CREATE_CHATROOM`、`CZ_REQ_ENTER_ROOM`、`CZ_CHANGE_CHATROOM`、`CZ_REQ_ROLE_CHANGE`、`CZ_REQ_EXPEL_MEMBER`、`CZ_EXIT_ROOM`
- **组队**：`CZ_MAKE_GROUP(2)`、`CZ_PARTY_JOIN_REQ`、`CZ_REQ_JOIN_GROUP`、`CZ_PARTY_JOIN_REQ_ACK`、`CZ_REQ_LEAVE_GROUP`、`CZ_REQ_EXPEL_GROUP_MEMBER`、`CZ_CHANGE_GROUP_MASTER`、`CZ_GROUPINFO_CHANGE_V2`
- **好友**：`CZ_ADD_FRIENDS`、`CZ_ACK_REQ_ADD_FRIENDS`、`CZ_DELETE_FRIENDS`
- **公会**：`CZ_REQ_MAKE_GUILD`、`CZ_REQ_GUILD_MENUINTERFACE`、`CZ_REQ_GUILD_MENU`、`CZ_REQ_JOIN_GUILD(2)`、`CZ_JOIN_GUILD`、`CZ_REQ_LEAVE_GUILD`、`CZ_REQ_BAN_GUILD`、`CZ_REQ_DISORGANIZE_GUILD`、`CZ_REQ_CHANGE_MEMBERPOS`、`CZ_REG_CHANGE_GUILD_POSITIONINFO`、`CZ_GUILD_NOTICE`、`CZ_REQ_ALLY_GUILD`、`CZ_ALLY_GUILD`、`CZ_REQ_HOSTILE_GUILD`、`CZ_REQ_DELETE_RELATED_GUILD`、`CZ_REGISTER_GUILD_EMBLEM_IMG`、`CZ_REQ_GUILD_EMBLEM_IMG`、`CZ_REQ_OPEN_MEMBER_INFO`
- **宠物、生命体、佣兵**：`CZ_TRYCAPTURE_MONSTER`、`CZ_SELECT_PETEGG`、`CZ_COMMAND_PET`、`CZ_PET_ACT`、`CZ_RENAME_PET`、`CZ_PET_EVOLUTION`、`CZ_COMMAND_MER`、`CZ_RENAME_MER`、`CZ_MER_COMMAND`、`CZ_REQUEST_MOVENPC`、`CZ_REQUEST_ACTNPC`、`CZ_REQUEST_MOVETOOWNER`
- **任务、成就、签到、排行**：`CZ_ACTIVE_QUEST`、`CZ_REQ_ACH_REWARD`、`CZ_REQ_CHECK_ATTENDANCE`、`CZ_UI_OPEN`、`CZ_RANKING`、`CZ_ALCHEMIST_RANK`、`CZ_BLACKSMITH_RANK`、`CZ_TAEKWON_RANK`、`CZ_REQ_USER_COUNT`
- **邮件**
  - RODEX：`CZ_OPEN_RODEXBOX`、`CZ_CLOSE_RODEXBOX`、`CZ_REQ_NEXT_RODEX`、`CZ_REQ_REFRESH_RODEX`、`CZ_REQ_READ_RODEX`、`CZ_REQ_ITEM_FROM_RODEX`、`CZ_REQ_ZENY_FROM_RODEX`、`CZ_REQ_DELETE_RODEX`、`CZ_REQ_OPEN_WRITE_RODEX`、`CZ_CHECK_RECEIVE_CHARACTER_NAME`、`CZ_CHECK_RODEX_RECEIVE`、`CZ_REQ_ADD_ITEM_RODEX`、`CZ_REQ_REMOVE_RODEX_ITEM`、`CZ_REQ_SEND_RODEX(2)`、`CZ_REQ_CANCEL_WRITE_RODEX`、`CZ_OPEN_ALL_RODEX`、`CZ_UPDATE_ALL_RODEX`
  - 旧版：`CZ_MAIL_*`、`CZ_REQ_MAIL_RETURN`
- **精炼和附魔**：`CZ_REFINING_SELECT_ITEM`、`CZ_REQ_REFINING`、`CZ_CLOSE_REFINING_UI`、`CZ_GRADE_ENCHANT_SELECT_EQUIPMENT`、`CZ_GRADE_ENCHANT_REQ`、`CZ_GRADE_ENCHANT_CLOSE_UI`、`CZ_REQUEST_RANDOM_ENCHANT`、`CZ_REQUEST_PERFECT_ENCHANT`、`CZ_REQUEST_UPGRADE_ENCHANT`、`CZ_REQUEST_RESET_ENCHANT`、`CZ_CLOSE_UI_ENCHANT`、`CZ_ITEM_REFORM`、`CZ_CLOSE_REFORM_UI`、`CZ_REQ_RANDOM_COMBINE_ITEM`、`CZ_RANDOM_COMBINE_ITEM_UI_CLOSE`、`CZ_REQ_RANDOM_UPGRADE_ITEM`、`CZ_RANDOM_UPGRADE_ITEM_UI_CLOSE`
- **银行、商城、轮盘**
  - 银行：`CZ_REQ_BANK_OPEN`、`CZ_REQ_BANKING_CHECK`、`CZ_REQ_BANKING_DEPOSIT`、`CZ_REQ_BANKING_WITHDRAW`、`CZ_REQ_BANK_CLOSE`
  - 商城：`CZ_SE_CASHSHOP_OPEN1/2`、`CZ_SE_PC_BUY_CASHITEM_LIST`、`CZ_CASH_SHOP_CLOSE`
  - 轮盘：`CZ_REQ_OPEN_ROULETTE`、`CZ_REQ_ROULETTE_INFO`、`CZ_REQ_GENERATE_ROULETTE`、`CZ_RECV_ROULETTE_ITEM`、`CZ_REQ_CLOSE_ROULETTE`
- **防外挂验证**：`CZ_ACK_ANSWER_MACRO_DETECTOR`、`CZ_REQ_UPLOAD_MACRO_DETECTOR`、`CZ_UPLOAD_MACRO_DETECTOR_CAPTCHA`、`CZ_REQ_PREVIEW_MACRO_DETECTOR`、`CZ_REQ_APPLY_MACRO_DETECTOR`、`CZ_REQ_PLAYER_AID_IN_RANGE`
- **GM**：`CZ_MOVETO_MAP`、`CZ_SHIFT`、`CZ_RECALL`、`CZ_RECALL_GID`、`CZ_CHANGE_EFFECTSTATE`、`CZ_DISCONNECT_CHARACTER`、`CZ_DISCONNECT_ALL_CHARACTER`、`CZ_ITEM_CREATE`、`CZ_RESET`、`CZ_REMOVE_AID`、`CZ_REQ_STATUS_GM`

## 附录 C：不需要对齐（或需要换一种方式实现）的 roBrowser 能力

- **Web 平台特有**
  - 包括：wsProxy / WebSocket / NodeSocket、Remote Client（HTTP 读取 GRF）、PWA / Electron 打包、`Core/Thread.js` 和 Worker、`MemoryManager`、`PluginManager` 插件系统、`Intro` 配置页（服务器列表、GRF 选择）。
  - 原生 App 已经用 `NetworkClient` 和 `ResourceManager` 覆盖了这些能力。
- **开发工具**
  - 包括：`App/GrfViewer`、`ModelViewer`、`StrViewer`、`EffectViewer`、`MapViewer`、`GrannyModelViewer`。
  - 这些不属于游戏客户端。RagnarokOffline App 本身有资源浏览功能，需要时可以单独评估。
- **录像回放**
  - roBrowser 可以解析和播放官方 `.rrf` 录像，并用虚拟 socket 驱动整个引擎。
  - 这个功能的前提是 `GameSession` 能接受来自非网络的包流。如果要做，建议在网络层抽象完成之后再做（P3）。
  - 参考：`Engine/Replay/*`
- **UI 版本切换**
  - roBrowser 可以在不同年代的官方 UI 皮肤之间切换。RagnarokGame 走 SwiftUI 路线，不需要对齐。
  - 参考：`UI/UIVersionManager.js`、各组件里的 V0–V4
- **MobileUI 和 JoystickUI 的触屏部分**
  - RagnarokGame 已经有原生的 `ThumbstickView` 和 `ActionControlPadView`，只需要补手柄支持（§24）。

## 附录 D：建议实施顺序

1. **P0 可玩性闭环**
   - 技能目标选择（§8.1）。
   - 实体名字和头顶聊天气泡（§6.1、§6.4）。
   - 组队、公会、氏族消息和私聊的发送（§15.1）。
   - 修正项中的 P0 / P1 部分（§2）。
2. **P1 表现层**
   - 状态外观和状态图标（§6.2、§8.3）。
   - 技能单元（§8.2）。
   - 按 SkillEffect / EffectTable 批量移植特效（§9）。
   - 伤害数字补齐和受击动作（§7）。
   - 表情（§6.4）。
3. **P1 社交与经济**：组队、好友、交易、摆摊、聊天室、玩家上下文菜单、手推车、公会仓库（§14、§15、§17）。
4. **P1 会话健壮性**：切换地图服、地图属性和 mapflag、服务端配置、退出流程、时间同步、PIN 码、删除角色流程（§3、§4、§5）。
5. **P1 设置与输入**：偏好持久化、音频设置、键盘快捷键、斜杠命令分发器（§12、§24、§25、§26）。
6. **P2 系统**：任务、公会、宠物 / 生命体 / 佣兵、RODEX、查看装备和插卡、技能树、导航、精炼、附魔、银行（§13、§18–§23）。
7. **P3**：运行时 PACKETVER、包混淆、GM 命令、后处理、商城、轮盘、录像回放。
