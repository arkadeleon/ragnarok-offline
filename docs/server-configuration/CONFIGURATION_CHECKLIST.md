# Server Configuration 实现清单

实施顺序与每日验收见 [分阶段实施计划](IMPLEMENTATION_PLAN.md)。

范围：当前仓库 rAthena conf。下列按页面列出要实现的设置；常用玩家配置优先，系统管理项放高级页或只读。字段值为仓库配置值，不等于 App 最终运行值；App 覆盖见后文。未核实项不得直接按猜测生成验证规则。

## 推荐的页面分类

所有 battle 子分类均写入 `battle_conf`，不是为每个文件增加一个写入接口。

| 页面 | 来源 | 覆盖内容 | 开放建议 |
|---|---|---|---|
| 经验与成长 | battle/exp.conf | Base/Job 倍率、死亡损失、经验分配、等级限制相关开关 | 常用 |
| 掉落与拾取 | battle/drops.conf | 普通/MVP/卡片等倍率、上下限、自动拾取、归属保护 | 常用 |
| 玩家属性 | battle/player.conf | HP/SP、攻速、移速、负重、属性上限、回复、保存 | 常用/高级 |
| 战斗规则 | battle/battle.conf | 战斗公式开关、伤害、目标、命中、地图战斗规则 | 高级 |
| 技能 | battle/skill.conf | 消耗、咏唱、延迟、范围、技能专属规则 | 高级 |
| 装备与制作 | battle/items.conf | 道具使用、装备、制造、药水、交易规则 | 常用/高级 |
| 怪物与 MVP | battle/monster.conf | AI、刷新、生命、技能、目标选择、Boss 规则 | 常用/高级 |
| 宠物 | battle/pet.conf | 亲密度、饥饿、喂食、捕获、协助战斗 | 常用 |
| 生命体 | battle/homunc.conf | 成长、饥饿、亲密度、经验、技能规则 | 常用 |
| 组队 | battle/party.conf | 共享经验、分配、显示、邀请 | 常用 |
| 公会与攻城 | battle/guild.conf | 公会经验、人数、技能及攻城规则 | 高级 |
| 战场 | battle/battleground.conf | 战场伤害及战斗限制 | 高级 |
| 副本 | battle/instance.conf | 实例限制、离队/换队长/邀请 | 高级 |
| 状态 | battle/status.conf | 状态持续、退出/死亡后保留规则 | 高级 |
| 客户端行为 | battle/client.conf | 显示、视野、路径、客户端兼容选项 | 高级；保护 App 必需值 |
| 功能开关 | battle/feature.conf | 商店、成就、签到、宠物进化等 | 高级；核实 PACKETVER |
| GM 与安全 | battle/gm.conf | GM 行为和权限相关规则 | 高级 |
| 其他游戏规则 | battle/misc.conf | 决斗、昼夜、聊天、邮件等杂项 | 常用/高级 |
| 角色与创建 | char_athena.conf | 名称、创建/删除/移动、初始地点、PIN、邮件等 | 常用/高级 |
| 账号与登录 | login_athena.conf | 注册、密码、登录限制、封禁和服务器连接 | 高级/系统管理 |
| 地图服务 | map_athena.conf | 服务端连接、地图进程及日志显示配置 | 系统管理 |
| 跨服与数据库 | inter_athena.conf | 数据库连接、表名等 | 系统管理；App 自动管理数据库名 |
| 网络 | packet_athena.conf、subnet_athena.conf | 超时、IP 规则、DDoS、子网路由 | 系统管理 |
| 脚本引擎 | script_athena.conf | 命令/跳转次数限制、输入上下限、类型警告 | 高级 |
| 日志 | log_athena.conf | 物品、聊天、交易及日志筛选 | 高级；位掩码专用控件 |
| Web 服务 | web_athena.conf | Web 监听、连接与输出 | 系统管理 |
| 地图列表 | maps_athena.conf | 重复的 map 键构成地图列表 | 列表编辑；不是 1,265 个独立开关 |
| 频道 | channels.conf | 颜色、私人频道、预设频道、联盟频道 | 结构化编辑器 |
| 指令与权限 | atcommands.yml、groups.yml | 指令别名/帮助、玩家组、继承、指令和权限 | 结构化编辑器 |
| 仓库 | inter_server.yml | 仓库 ID、名称、表名、容量 | 结构化编辑器 |
| 消息与公告 | msg_conf/*、motd.txt、charhelp.txt | 多语言消息编号、公告和帮助 | 本地化/多行文本编辑器 |
| 资源路径 | grf-files.txt | GRF 列表、data_dir | 系统管理；使用文件选择器 |
| 开发工具 | valkyrie_sample.cfg | Valgrind/Valkyrie 调试配置 | 不放入玩家配置页 |

## 结构化配置字段

这些文件不能用通用 `key: value` 标量表单处理；完整实例、注释和默认模板见对应 conf 源文件。

| 对象 | 完整字段/结构 | UI |
|---|---|---|
| atcommands.yml | Header.Type/Version；Body[].Command、Aliases[]、Help；Footer.Imports[].Path | 指令搜索、别名列表、多行帮助；Header 和导入路径由系统管理 |
| groups.yml | Header.Type/Version；Body[].Id、Name、Level、LogCommands、Commands{指令:布尔}、CharCommands{指令:布尔}、Permissions{权限:布尔}、Inherit{组名:布尔}；Footer.Imports[].Path | 组列表、权限矩阵、继承选择；检查 ID 唯一与循环继承 |
| inter_server.yml | Header.Type/Version；Body[].ID、Name、Table、Max；Footer.Imports[].Path | 仓库列表；Table 关联实际数据库表，不能任意承诺新增即可用 |
| channel_config.colors | 可扩展名称 → 颜色字符串 | 颜色列表/选择器 |
| channel_config.private_channel | allow、color、delay、max_member、self_notif、join_notif、leave_notif、ban、kick、color_override、change_delay | 开关、颜色引用、延迟和人数 |
| channel_config.channels[] | name、password、alias、color、type、autojoin、delay、leave、chat、color_override、self_notif、join_notif、leave_notif、groupid[] | 频道列表；密码保护；type 为 PUBLIC/ALLY/MAP 类型常量 |
| channel_config.map | 与频道对象同类结构；CHAN_TYPE_MAP 不允许修改 | 地图频道专用编辑 |
| channel_config.ally | 与频道对象同类结构；CHAN_TYPE_ALLY 不允许修改 | 联盟频道专用编辑 |
| subnet | 子网掩码:char_ip:map_ip，最多 16 条（文件注释） | 三列路由列表 |
| msg_conf | 编号 → 消息文本；import 为导入指令 | 保留 printf 格式占位符及消息编号，不按普通数值字段编辑 |
| motd / charhelp | 整文件文本 | 多行编辑；保留颜色/控制代码 |
| grf-files | 可重复 grf、data_dir | 有序路径列表 |

YAML 具体可用命令/权限及频道实例以对应源文件为准；上表是字段结构清单，不把实例值误当成固定枚举。YAML 字段未伪装成已通过解析验证的标量 标量条目。

## 默认值与覆盖策略

必须区分：源码初始化值 → 基础 conf 值 → import 覆盖值 → 加载后的调整值。`字段表` 的值是文件原文，不是运行态最终值；表中源码范围来自 battle.cpp 注册表。注册表可能受编译条件影响，宏表达式不能直接当十进制值使用。

当前 App 在 `RagnarokOffline/Server/ServerManager.swift` 明确覆盖：

- battle：`area_size: 26`、`max_walk_path: 32`。
- char：`login_ip: 127.0.0.1`、`stdout_with_ansisequence: yes`、`char_name_option: 0`、`char_del_delay: 0`、`pincode_enabled: no`。
- login：`stdout_with_ansisequence: yes`、`new_account: yes`。
- map：`char_ip: 127.0.0.1`、`stdout_with_ansisequence: yes`。
- web：`stdout_with_ansisequence: yes`。
- groups：为组 0 增加移动、转职、复活、治疗、物品、升级、召怪、金钱、属性、骑乘、自动拾取、特效等命令及 any_warp 权限，具体清单见 `RagnarokOffline/Server/ServerManager.swift`。

`ServerConfiguration.updateInterServerConfiguration` 还会最后追加六项数据库名，根据模式使用 ragnarok 或 ragnarok-pre，用户覆盖不应与其竞争。

`ServerResourceManager.prepareWorkingDirectory` 每次会删除重建 conf/import，再写入 ServerConfiguration。因此用户配置必须持久化到 App 模型，再生成 import；直接编辑工作目录会丢失。配置资源升级也会重新复制 conf/db/npc。

当前 ServerConfiguration 仅提供 12 个覆盖入口：atcommands、battle_conf、char_conf、groups、inter_conf、inter_server、log_conf、login_conf、map_conf、packet_conf、script_conf、web_conf。频道、地图、子网、消息、公告、GRF 等需要扩展资源写入策略，不能仅添加 UI 就宣称支持。

## 表单实现约束

1. `yes/no`、`true/false` 和注册范围 0..1 才是明确开关；值为 0/1 的普通整数不能仅凭当前值推定布尔。
2. 百分比和倍率须按注释逐项处理。例如经验 100 通常展示为 1×，不是 100×；时间有毫秒、秒、分钟、天，不统一猜测。位掩码要按注释逐位多选，枚举与掩码不能混用。
3. 重复键、列表、冒号复合值、空值、字符串中的 //、YAML 多行 Help 均须按对应解析器处理，不能全局字典化。注释中的示例和 Note/Default 等说明行是“注释候选”，不是已确认配置项。
4. 每个 UI 项后续补中文标题、帮助、单位、枚举值、模式条件、控件、序列化、依赖关系和测试。自动推导的控件只是建议。没有源码范围的项保持“未核实”，不能给任意安全范围。
5. Renewal/Pre-Renewal、PACKETVER、编译宏和 battle_adjust_conf 会使部分值无效或被修正；UI 应按实际构建条件筛选，不能简单全开放。
6. 第一版按保存后完整重启服务器设计。源码虽有 reloadbattleconf/logconf/msgconf 等命令，但不表示所有配置支持热更新；不要承诺调整已有角色属性、技能或地图状态立即生效。
7. 提供单项/分类恢复默认、覆盖预览、搜索；“恢复默认”应删除用户覆盖并保留 App 必需覆盖。重启失败应回滚上次可启动配置。
8. 数据库、内部连接、端口、密码、脚本安全限制放系统管理或保持只读；常用玩家页聚焦游戏体验设置。


## 逐项实现字段

同名字段按来源文件区分。注释候选表示配置文件中未启用，需核对读取器；不把说明文字、消息编号和重复地图条目当独立设置。范围未提供的字段必须核对源码，不能凭当前值猜测。位掩码/枚举的具体选项按该字段源文件注释实现。

### battle/battle.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| enable_baseatk | 0x9 | 位掩码多选（按注释定义） | BL_NUL…BL_ALL | 已启用；源文件第 13 行 |
| enable_baseatk_renewal | 0x29F | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 14 行 |
| enable_perfect_flee | 1 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 17 行 |
| enable_critical | 17 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 21 行 |
| mob_critical_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 24 行 |
| critical_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 25 行 |
| attack_walk_delay | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 33 行 |
| damage_walk_delay | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 40 行 |
| pc_damage_walk_delay_rate | 20 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 45 行 |
| damage_walk_delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 46 行 |
| multihit_delay | 200 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 55 行 |
| player_damage_delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 59 行 |
| infinite_endure | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 65 行 |
| undead_detect_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 72 行 |
| attribute_recover | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 75 行 |
| min_hitrate | 5 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 78 行 |
| max_hitrate | 100 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 79 行 |
| agi_penalty_type | 1 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 85 行 |
| agi_penalty_target | 1 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 89 行 |
| agi_penalty_count | 3 | 数值输入（枚举/单位须按说明确认） | 2…INT_MAX | 已启用；源文件第 92 行 |
| agi_penalty_num | 10 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 95 行 |
| vit_penalty_type | 1 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 101 行 |
| vit_penalty_target | 1 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 105 行 |
| vit_penalty_count | 3 | 数值输入（枚举/单位须按说明确认） | 2…INT_MAX | 已启用；源文件第 108 行 |
| vit_penalty_num | 5 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 111 行 |
| eg | 10 + 50 def becomes 0 + (10*type + 50) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 116 行 |
| weapon_defense_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 117 行 |
| magic_defense_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 120 行 |
| attack_direction_change | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 128 行 |
| attack_attr_none | 14 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 134 行 |
| equip_natural_break_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 138 行 |
| equip_self_break_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 144 行 |
| equip_skill_break_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 148 行 |
| delay_battle_damage | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 153 行 |
| synchronize_damage | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 161 行 |
| arrow_decrement | 1 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 169 行 |
| ammo_unequip | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 173 行 |
| ammo_check_weapon | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 177 行 |
| autospell_check_range | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 183 行 |
| knockback_left | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 187 行 |
| warg_can_falcon | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 191 行 |
| snap_dodge | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 195 行 |
| break_mob_equip | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 201 行 |

### battle/battleground.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| bg_short_attack_damage_rate | 80 | 位掩码多选（按注释定义） | 0…INT_MAX | 已启用；源文件第 13 行 |
| bg_long_attack_damage_rate | 80 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 16 行 |
| bg_weapon_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 19 行 |
| bg_magic_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 22 行 |
| bg_misc_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 25 行 |
| bg_flee_penalty | 20 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 29 行 |
| bg_update_interval | 1000 | 数值输入（枚举/单位须按说明确认） | 100…INT_MAX | 已启用；源文件第 32 行 |
| bgqueue_nowarp_mapflag | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 36 行 |

### battle/client.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| min_chat_delay | 0 | 位掩码多选（按注释定义） | 0…INT_MAX | 已启用；源文件第 14 行 |
| min_hair_style | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 17 行 |
| max_hair_style | 42 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 18 行 |
| min_hair_color | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 19 行 |
| max_hair_color | 8 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 20 行 |
| min_cloth_color | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 21 行 |
| max_cloth_color | 7 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 22 行 |
| hide_woe_damage | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 27 行 |
| pet_hair_style | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 36 行 |
| area_size | 14 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 39 行 |
| max_walk_path | 17 | 数值输入（枚举/单位须按说明确认） | 1…MAX_WALKPATH | 已启用；源文件第 42 行 |
| max_lv | 99 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 49 行 |
| aura_lv | 99 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 57 行 |
| client_limit_unit_lv | 0 | 数值输入（枚举/单位须按说明确认） | 0…BL_ALL | 已启用；源文件第 63 行 |
| wedding_modifydisplay | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 66 行 |
| save_clothcolor | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 69 行 |
| save_body_style | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 72 行 |
| wedding_ignorepalette | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 78 行 |
| xmas_ignorepalette | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 82 行 |
| summer_ignorepalette | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 86 行 |
| hanbok_ignorepalette | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 90 行 |
| oktoberfest_ignorepalette | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 94 行 |
| motd_type | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 97 行 |
| display_version | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 100 行 |
| display_hallucination | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 104 行 |
| display_status_timers | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 108 行 |
| client_reshuffle_dice | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 112 行 |
| client_sort_storage | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 117 行 |
| update_enemy_position | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 123 行 |
| spawn_direction | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 127 行 |
| mvp_exp_reward_message | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 132 行 |
| ping_timer_inverval | 30 | 数值输入（枚举/单位须按说明确认） | 0…99999999 | 已启用；源文件第 136 行 |
| ping_time | 20 | 数值输入（枚举/单位须按说明确认） | 0…99999999 | 已启用；源文件第 139 行 |
| show_skill_scale | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 143 行 |
| drop_connection_on_quit | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 148 行 |
| macro_detection_retry | 3 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 153 行 |
| macro_detection_timeout | 60000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 158 行 |
| macro_detection_punishment | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 164 行 |
| macro_detection_punishment_time | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 169 行 |
| macrochecker_delay | 600000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 173 行 |
| hide_cloaked_units | 0 | 数值输入（枚举/单位须按说明确认） | 0…BL_ALL | 已启用；源文件第 177 行 |

### battle/drops.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| item_auto_get | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 11 行 |
| flooritem_lifetime | 60000 | 数值输入（枚举/单位须按说明确认） | 1000…INT_MAX | 已启用；源文件第 14 行 |
| first_attack_loot_bonus | 30 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 22 行 |
| mvp_to_loot_priority | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 27 行 |
| item_first_get_time | 3000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 30 行 |
| item_second_get_time | 2000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 34 行 |
| item_third_get_time | 2000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 38 行 |
| mvp_item_first_get_time | 10000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 42 行 |
| mvp_item_second_get_time | 10000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 47 行 |
| mvp_item_third_get_time | 2000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 52 行 |
| item_rate_common | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 57 行 |
| item_rate_common_boss | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 58 行 |
| item_rate_common_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 59 行 |
| item_drop_common_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 60 行 |
| item_drop_common_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 61 行 |
| item_rate_heal | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 64 行 |
| item_rate_heal_boss | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 65 行 |
| item_rate_heal_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 66 行 |
| item_drop_heal_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 67 行 |
| item_drop_heal_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 68 行 |
| item_rate_use | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 71 行 |
| item_rate_use_boss | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 72 行 |
| item_rate_use_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 73 行 |
| item_drop_use_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 74 行 |
| item_drop_use_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 75 行 |
| item_rate_equip | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 78 行 |
| item_rate_equip_boss | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 79 行 |
| item_rate_equip_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 80 行 |
| item_drop_equip_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 81 行 |
| item_drop_equip_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 82 行 |
| item_rate_card | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 85 行 |
| item_rate_card_boss | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 86 行 |
| item_rate_card_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 87 行 |
| item_drop_card_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 88 行 |
| item_drop_card_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 89 行 |
| item_rate_mvp | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 93 行 |
| item_drop_mvp_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 94 行 |
| item_drop_mvp_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 95 行 |
| item_drop_mvp_mode | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 96 行 |
| item_rate_adddrop | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 99 行 |
| item_drop_add_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 100 行 |
| item_drop_add_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 101 行 |
| item_group_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 105 行 |
| item_group_drop_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 106 行 |
| item_group_drop_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 107 行 |
| item_rate_treasure | 100 | 数值输入（枚举/单位须按说明确认） | 0…1000000 | 已启用；源文件第 110 行 |
| item_drop_treasure_min | 1 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 111 行 |
| item_drop_treasure_max | 10000 | 数值输入（枚举/单位须按说明确认） | 1…10000 | 已启用；源文件第 112 行 |
| item_logarithmic_drops | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 133 行 |
| drop_rate0item | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 137 行 |
| drop_rateincrease | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 143 行 |
| drops_by_luk | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 148 行 |
| drops_by_luk2 | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 153 行 |
| 0 | Nothing drops. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 157 行 |
| 1 | Only marine spheres drop items. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 158 行 |
| 2 | All alchemist summons drop items. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 159 行 |
| alchemist_summon_reward | 1 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 160 行 |
| rare_drop_announce | 0 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 169 行 |
| autoloot_adjust | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 174 行 |
| mercenary_autoloot | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 177 行 |
| mer_idle_no_share | no | 开关（编码保留原格式） | 0…INT_MAX | 已启用；源文件第 187 行 |
| idletime_mer_option | 0x1F | 数值输入（枚举/单位须按说明确认） | 0x1…0xFFF | 已启用；源文件第 206 行 |
| drop_rate_cap | 9000 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 209 行 |
| drop_rate_cap_vip | 9000 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 210 行 |
| rndopt_drop_pillar | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 213 行 |
| enable_bonus_map_drops | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 217 行 |

### battle/exp.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| base_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 13 行 |
| job_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 16 行 |
| multi_level_up | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 19 行 |
| multi_level_up_base | 0 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 24 行 |
| multi_level_up_job | 0 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 25 行 |
| max_exp_gain_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 31 行 |
| exp_calc_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 37 行 |
| exp_bonus_attacker | 25 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 42 行 |
| exp_bonus_max_attacker | 12 | 数值输入（枚举/单位须按说明确认） | 2…INT_MAX | 已启用；源文件第 46 行 |
| exp_bonus_nodamage_attacker | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 51 行 |
| mvp_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 54 行 |
| quest_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 57 行 |
| heal_exp | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 61 行 |
| resurrection_exp | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 65 行 |
| shop_exp | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 70 行 |
| pvp_exp | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 74 行 |
| death_penalty_type | 1 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 80 行 |
| death_penalty_base | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 83 行 |
| death_penalty_job | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 86 行 |
| zeny_penalty | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 90 行 |
| 0 | Never lose (default as in official). | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 93 行 |
| 1 | Lose Base EXP. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 94 行 |
| 2 | Lose Job EXP. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 95 行 |
| death_penalty_maxlv | 0 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 96 行 |
| disp_experience | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 99 行 |
| disp_zeny | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 102 行 |
| use_statpoint_table | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 107 行 |
| use_traitpoint_table | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 112 行 |
| exp_cost_redemptio | 1 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 115 行 |
| exp_cost_redemptio_limit | 5 | 数值输入（枚举/单位须按说明确认） | 0…MAX_PARTY | 已启用；源文件第 120 行 |

### battle/feature.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| feature.buying_store | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 12 行 |
| feature.search_stores | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 16 行 |
| feature.atcommand_suggestions | off | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 20 行 |
| feature.auction | off | 开关（编码保留原格式） | 0…2 | 已启用；源文件第 26 行 |
| feature.warp_suggestions | off | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 30 行 |
| feature.banking | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 34 行 |
| feature.banking_state_enforce | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 39 行 |
| feature.autotrade | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 43 行 |
| feature.autotrade_direction | 4 | 数值输入（枚举/单位须按说明确认） | -1…7 | 已启用；源文件第 49 行 |
| feature.autotrade_head_direction | 0 | 数值输入（枚举/单位须按说明确认） | -1…2 | 已启用；源文件第 56 行 |
| feature.autotrade_sit | 1 | 数值输入（枚举/单位须按说明确认） | -1…1 | 已启用；源文件第 62 行 |
| feature.autotrade_open_delay | 5000 | 数值输入（枚举/单位须按说明确认） | 1000…INT_MAX | 已启用；源文件第 65 行 |
| feature.bgqueue | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 69 行 |
| feature.roulette | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 73 行 |
| feature.roulette_bonus_reward | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 77 行 |
| feature.achievement | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 81 行 |
| feature.refineui | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 85 行 |
| feature.equipswitch | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 89 行 |
| feature.petevolution | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 93 行 |
| feature.petautofeed | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 97 行 |
| feature.pet_autofeed_rate | 89 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 101 行 |
| feature.homunculus_autofeed | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 105 行 |
| feature.homunculus_autofeed_rate | 30 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 114 行 |
| feature.attendance | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 118 行 |
| feature.privateairship | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 122 行 |
| feature.barter | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 126 行 |
| feature.barter_extended | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 130 行 |
| feature.dynamicnpc_timeout | 60000 | 数值输入（枚举/单位须按说明确认） | 60000…INT_MAX | 已启用；源文件第 134 行 |
| feature.dynamicnpc_rangex | 2 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 138 行 |
| feature.dynamicnpc_rangey | 2 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 142 行 |
| feature.dynamicnpc_direction | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 146 行 |
| feature.itemlink | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 153 行 |
| feature.mesitemlink | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 158 行 |
| feature.mesitemlink_brackets | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 162 行 |
| feature.mesitemlink_dbname | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 166 行 |
| feature.mesitemicon | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 171 行 |
| feature.mesitemicon_dbname | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 175 行 |
| feature.stylist | on | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 179 行 |
| feature.instance_allow_reconnect | yes | 开关（编码保留原格式） | 0…1；0…1 | 注释候选；源文件第 186 行 |

### battle/gm.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| atcommand_symbol | @ | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 18 行 |
| charcommand_symbol | # | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 19 行 |
| atcommand_spawn_quantity_limit | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 22 行 |
| atcommand_slave_clone_limit | 25 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 25 行 |
| partial_name_scan | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 32 行 |
| ban_hack_trade | 5 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 36 行 |
| atcommand_mobinfo_type | 1 | 开关（0/1） | 0…1 | 已启用；源文件第 42 行 |
| atcommand_levelup_events | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 47 行 |
| atcommand_disable_npc | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 53 行 |

### battle/guild.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| guild_emperium_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 11 行 |
| guild_exp_limit | 50 | 数值输入（枚举/单位须按说明确认） | 0…99 | 已启用；源文件第 14 行 |
| guild_max_castles | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 17 行 |
| guild_skill_relog_type | 0 | 开关（0/1） | 0…1；0…1 | 注释候选；源文件第 23 行 |
| guild_skill_relog_delay | 300000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 28 行 |
| gvg_short_attack_damage_rate | 80 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 31 行 |
| gvg_long_attack_damage_rate | 80 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 34 行 |
| gvg_weapon_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 37 行 |
| gvg_magic_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 40 行 |
| gvg_misc_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 43 行 |
| gvg_flee_penalty | 20 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 47 行 |
| require_glory_guild | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 52 行 |
| max_guild_alliance | 3 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 57 行 |
| guild_notice_changemap | 2 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 63 行 |
| guild_maprespawn_clones | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 67 行 |
| guild_leaderchange_delay | 1440 | 数值输入（枚举/单位须按说明确认） | 0…INT32_MAX | 已启用；源文件第 72 行 |
| guild_leaderchange_woe | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 76 行 |
| guild_alliance_onlygm | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 80 行 |

### battle/homunc.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| hom_setting | 0x3D | 位掩码多选（按注释定义） | 0x0000…0xFFFF | 已启用；源文件第 20 行 |
| hom_delay_reset_vaporize | no | 开关（编码保留原格式） | 0…1；0…1 | 注释候选；源文件第 25 行 |
| hom_delay_reset_warp | no | 开关（编码保留原格式） | 0…1；0…1 | 注释候选；源文件第 30 行 |
| homunculus_friendly_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 33 行 |
| hom_rename | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 36 行 |
| homunculus_evo_intimacy_need | 91100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 39 行 |
| homunculus_evo_intimacy_reset | 1000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 42 行 |
| hvan_explosion_intimate | 45000 | 数值输入（枚举/单位须按说明确认） | 0…100000 | 已启用；源文件第 45 行 |
| homunculus_show_growth | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 48 行 |
| homunculus_autoloot | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 51 行 |
| homunculus_auto_vapor | 80 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 55 行 |
| homunculus_max_level | 99 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 58 行 |
| homunculus_S_max_level | 275 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 61 行 |
| homunculus_S_growth_level | 99 | 数值输入（枚举/单位须按说明确认） | 0…MAX_LEVEL | 已启用；源文件第 67 行 |
| homunculus_autofeed_always | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 71 行 |
| hom_idle_no_share | no | 开关（编码保留原格式） | 0…INT_MAX | 已启用；源文件第 81 行 |
| idletime_hom_option | 0x1F | 数值输入（枚举/单位须按说明确认） | 0x1…0xFFF | 已启用；源文件第 100 行 |
| homunculus_exp_gain | 10 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 105 行 |
| homunculus_starving_rate | 10 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 111 行 |
| homunculus_starving_delay | 20000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 115 行 |

### battle/instance.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| instance_block_leave | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 14 行 |
| instance_block_leaderchange | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 18 行 |
| instance_block_invite | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 23 行 |
| instance_block_expulsion | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 27 行 |

### battle/items.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| vending_max_value | 1000000000 | 位掩码多选（按注释定义） | 1…MAX_ZENY | 已启用；源文件第 13 行 |
| vending_over_max | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 19 行 |
| vending_tax | 500 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 24 行 |
| vending_tax_min | 100000000 | 数值输入（枚举/单位须按说明确认） | 0…MAX_ZENY | 已启用；源文件第 29 行 |
| buyer_name | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 32 行 |
| weapon_produce_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 35 行 |
| potion_produce_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 38 行 |
| produce_item_name_input | 0x03 | 数值输入（枚举/单位须按说明确认） | 0…0x9F | 已启用；源文件第 47 行 |
| dead_branch_active | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 50 行 |
| random_monster_checklv | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 55 行 |
| item_check | 0x0 | 数值输入（枚举/单位须按说明确认） | 0x0…0x7 | 已启用；源文件第 63 行 |
| item_use_interval | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 68 行 |
| cashfood_use_interval | 60000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 71 行 |
| gtb_sc_immunity | 50 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 76 行 |
| autospell_stacking | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 81 行 |
| allow_consume_restricted_item | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 86 行 |
| allow_equip_restricted_item | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 92 行 |
| item_enabled_npc | yes | 开关（编码保留原格式） | 0…1；0…1 | 注释候选；源文件第 96 行 |
| item_flooritem_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 101 行 |
| default_bind_on_equip | 4 | 数值输入（枚举/单位须按说明确认） | BOUND_NONE…BOUND_MAX-1 | 已启用；源文件第 109 行 |
| allow_bound_sell | 0x0 | 数值输入（枚举/单位须按说明确认） | 0…0xF | 已启用；源文件第 118 行 |
| broadcast_hide_name | 2 | 数值输入（枚举/单位须按说明确认） | 0…NAME_LENGTH | 已启用；源文件第 124 行 |
| rental_transaction | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 127 行 |
| rental_item_novalue | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 130 行 |
| min_shop_buy | 1 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 134 行 |
| min_shop_sell | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 138 行 |
| cardfix_monster_physical | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 144 行 |
| trade_count_stackable | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 149 行 |

### battle/misc.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| pk_mode | 0 | 位掩码多选（按注释定义） | 0…2 | 已启用；源文件第 19 行 |
| pk_mode_mes | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 23 行 |
| 0 | No penalties. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 27 行 |
| 1 | Disables chatting (includes whispers, party/guild msgs, etc) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 28 行 |
| 2 | Disables skill usage | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 29 行 |
| 4 | Disables commands usage | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 30 行 |
| 8 | Disables item usage/picking/dropping | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 31 行 |
| 16 | Disables room creation (chatrooms and vending shops) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 32 行 |
| manner_system | 15 | 数值输入（枚举/单位须按说明确认） | 0…0xFFF | 已启用；源文件第 33 行 |
| pk_min_level | 55 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 36 行 |
| pk_level_range | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 40 行 |
| pk_short_attack_damage_rate | 80 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 44 行 |
| pk_long_attack_damage_rate | 70 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 45 行 |
| pk_weapon_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 46 行 |
| pk_magic_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 47 行 |
| pk_misc_attack_damage_rate | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 48 行 |
| skill_log | off | 开关（编码保留原格式） | BL_NUL…BL_ALL | 已启用；源文件第 51 行 |
| battle_log | off | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 54 行 |
| etc_log | off | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 57 行 |
| warp_point_debug | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 62 行 |
| night_at_start | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 65 行 |
| day_duration | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 70 行 |
| night_duration | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 75 行 |
| duel_allow_pvp | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 78 行 |
| duel_allow_gvg | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 81 行 |
| duel_allow_teleport | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 84 行 |
| duel_autoleave_when_die | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 87 行 |
| duel_time_interval | 60 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 90 行 |
| duel_only_on_same_map | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 93 行 |
| official_cell_stack_limit | 1 | 数值输入（枚举/单位须按说明确认） | 0…255 | 已启用；源文件第 103 行 |
| custom_cell_stack_limit | 1 | 数值输入（枚举/单位须按说明确认） | 1…255 | 已启用；源文件第 104 行 |
| at_mapflag | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 109 行 |
| at_timeout | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 112 行 |
| at_monsterignore | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 115 行 |
| at_logout_event | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 118 行 |
| auction_feeperhour | 12000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 121 行 |
| auction_maximumprice | 500000000 | 数值输入（枚举/单位须按说明确认） | 0…MAX_ZENY | 已启用；源文件第 124 行 |
| searchstore_querydelay | 10 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 127 行 |
| searchstore_maxresults | 30 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 131 行 |
| cashshop_show_points | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 135 行 |
| mail_show_status | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 142 行 |
| mail_daily_count | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT32_MAX | 已启用；源文件第 147 行 |
| mail_zeny_fee | 2 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 153 行 |
| mail_attachment_price | 2500 | 数值输入（枚举/单位须按说明确认） | 0…INT32_MAX | 已启用；源文件第 159 行 |
| mail_attachment_weight | 2000 | 数值输入（枚举/单位须按说明确认） | 0…INT32_MAX | 已启用；源文件第 165 行 |
| mon_trans_disable_in_gvg | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 169 行 |
| discount_item_point_shop | 0 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 176 行 |
| disp_servervip_msg | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 179 行 |
| mail_delay | 1000 | 数值输入（枚举/单位须按说明确认） | 1000…INT_MAX | 已启用；源文件第 182 行 |
| hide_fav_sell | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 185 行 |
| map_edge_size | 15 | 数值输入（枚举/单位须按说明确认） | 1…40 | 已启用；源文件第 192 行 |
| item_stacking | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 199 行 |

### battle/monster.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| mvp_hp_rate | 100 | 位掩码多选（按注释定义） | 1…INT_MAX | 已启用；源文件第 13 行 |
| monster_hp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 16 行 |
| monster_ai | 0 | 数值输入（枚举/单位须按说明确认） | 0x0000…0x3FFF | 已启用；源文件第 62 行 |
| 0 | Every 100ms (MIN_MOBTHINKTIME) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 65 行 |
| 1 | Every cell moved | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 66 行 |
| x | Every x cells moved or one cell before the end of the chase path | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 67 行 |
| monster_chase_refresh | 32 | 数值输入（枚举/单位须按说明确认） | 0…MAX_WALKPATH | 已启用；源文件第 74 行 |
| 2 | Enable mob-warping when standing on Priest Warp Portals | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 79 行 |
| 4 | Disable warping when the target map is a 'nobranch' map. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 80 行 |
| 8 | Enable mob-warping when standing on Dimensional Door | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 81 行 |
| mob_warp | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4\|8 | 已启用；源文件第 82 行 |
| mob_active_time | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 89 行 |
| boss_active_time | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 90 行 |
| view_range_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 93 行 |
| chase_range_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 98 行 |
| monster_eye_range_bonus | 0 | 数值输入（枚举/单位须按说明确认） | 0…10 | 已启用；源文件第 104 行 |
| loot_range | 12 | 数值输入（枚举/单位须按说明确认） | 1…MAX_WALKPATH | 已启用；源文件第 109 行 |
| assist_range | 11 | 数值输入（枚举/单位须按说明确认） | 1…MAX_WALKPATH | 已启用；源文件第 114 行 |
| monster_active_enable | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 117 行 |
| override_mob_names | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 123 行 |
| monster_damage_delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 127 行 |
| monster_loot_type | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 132 行 |
| monster_loot_search_type | 1 | 开关（0/1） | 0…1 | 已启用；源文件第 137 行 |
| mob_skill_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 142 行 |
| mob_skill_delay | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 148 行 |
| mob_count_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 151 行 |
| mob_spawn_delay | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 155 行 |
| plant_spawn_delay | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 156 行 |
| boss_spawn_delay | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 157 行 |
| 3 | All monsters (legacy Athena) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 164 行 |
| mob_spawn_variance | 1 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 165 行 |
| no_spawn_on_player | 0 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 174 行 |
| force_random_spawn | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 179 行 |
| randomize_center_cell | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 188 行 |
| slaves_inherit_mode | 4 | 数值输入（枚举/单位须按说明确认） | 0…4 | 已启用；源文件第 196 行 |
| slaves_inherit_speed | 3 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 206 行 |
| mob_slave_keep_target | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 209 行 |
| slave_stick_with_master | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 213 行 |
| slave_active_with_master | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 217 行 |
| summons_trigger_autospells | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 221 行 |
| retaliate_to_master | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 225 行 |
| eg | Mob attacks player B, and player A casts a skill C. If set to yes and the | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 228 行 |
| mob_changetarget_byskill | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 231 行 |
| monster_class_change_full_recover | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 234 行 |
| show_mob_info | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4 | 已启用；源文件第 241 行 |
| zeny_from_mobs | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 244 行 |
| mobs_level_up | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 249 行 |
| mobs_level_up_exp_rate | 1 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 250 行 |
| dynamic_mobs | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 254 行 |
| mob_remove_damaged | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 257 行 |
| mob_remove_delay | 300000 | 数值输入（枚举/单位须按说明确认） | 1000…INT_MAX | 已启用；源文件第 260 行 |
| mob_npc_event_type | 1 | 开关（0/1） | 0…1 | 已启用；源文件第 266 行 |
| ksprotection | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 272 行 |
| mvp_tomb_enabled | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 276 行 |
| mvp_tomb_delay | 9000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 280 行 |
| mob_size_influence | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 286 行 |
| mob_icewall_walk_block | 75 | 数值输入（枚举/单位须按说明确认） | 0…255 | 已启用；源文件第 301 行 |
| boss_icewall_walk_block | 0 | 数值输入（枚举/单位须按说明确认） | 0…255 | 已启用；源文件第 302 行 |
| monster_hp_bars_info | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 306 行 |
| monster_stuck_warning | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 311 行 |
| mob_nopc_idleskill_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 317 行 |
| boss_nopc_idleskill_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 318 行 |
| mob_nopc_move_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 323 行 |
| boss_nopc_move_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 324 行 |
| achievement_mob_share | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 328 行 |
| mob_respawn_time | 1000 | 数值输入（枚举/单位须按说明确认） | 1000…INT_MAX | 已启用；源文件第 333 行 |
| mob_unlock_time | 2000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 338 行 |

### battle/party.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| show_steal_in_same_party | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 11 行 |
| party_update_interval | 1000 | 数值输入（枚举/单位须按说明确认） | 100…INT_MAX | 已启用；源文件第 14 行 |
| 0 | Aegis - bar is updated every time HP changes (bandwidth intensive) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 17 行 |
| 1 | rAthena - bar is updated with the party map dots (up to 1 second delay) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 18 行 |
| party_hp_mode | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 19 行 |
| show_party_share_picker | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 27 行 |
| 16 | IT_WEAPON,   32:  IT_ARMOR,    64:   IT_CARD,   128:  IT_PETEGG, | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 31 行 |
| 256 | IT_PETARMOR, 512: IT_UNKNOWN2, 1024: IT_AMMO,   2048: IT_DELAYCONSUME | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 32 行 |
| 262144 | IT_CASH | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 33 行 |
| show_picker.item_type | 112 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 34 行 |
| 2 | Round Robin (items are distributed evenly and in order among members) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 40 行 |
| 3 | 1+2 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 41 行 |
| party_item_share_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|3 | 已启用；源文件第 42 行 |
| idle_no_share | no | 开关（编码保留原格式） | 0…INT_MAX | 已启用；源文件第 49 行 |
| party_even_share_bonus | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 54 行 |
| display_party_name | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 58 行 |
| block_account_in_same_party | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 61 行 |
| change_party_leader_samemap | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 64 行 |

### battle/pet.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| pet_legacy_formula | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 17 行 |
| pet_catch_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 20 行 |
| pet_distance_check | 5 | 数值输入（枚举/单位须按说明确认） | 0…50 | 已启用；源文件第 26 行 |
| pet_hide_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 29 行 |
| pet_rename | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 32 行 |
| pet_friendly_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 35 行 |
| pet_hungry_delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 10…INT_MAX | 已启用；源文件第 38 行 |
| pet_equip_required | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 42 行 |
| pet_unequip_destroy | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 46 行 |
| pet_attack_support | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 49 行 |
| pet_damage_support | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 52 行 |
| pet_support_min_friendly | 900 | 数值输入（枚举/单位须按说明确认） | 0…950 | 已启用；源文件第 57 行 |
| pet_status_support | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 62 行 |
| pet_support_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 66 行 |
| pet_attack_exp_to_master | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 69 行 |
| pet_attack_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 72 行 |
| pet_lv_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 77 行 |
| pet_max_stats | 99 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 80 行 |
| pet_max_atk1 | 500 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 85 行 |
| pet_max_atk2 | 1000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 86 行 |
| pet_disable_in_gvg | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 91 行 |
| pet_ignore_infinite_def | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 94 行 |
| pet_master_dead | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 97 行 |
| pet_autofeed_always | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 101 行 |
| 1 | Master's walk speed (official) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 104 行 |
| 2 | DEFAULT_WALK_SPEED value | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 105 行 |
| 3 | Mob database walk speed | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 106 行 |
| pet_walk_speed | 1 | 数值输入（枚举/单位须按说明确认） | 1…3 | 已启用；源文件第 107 行 |

### battle/player.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| hp_rate | 100 | 位掩码多选（按注释定义） | 1…INT_MAX | 已启用；源文件第 13 行 |
| sp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 16 行 |
| left_cardfix_to_right | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 20 行 |
| restart_hp_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 24 行 |
| restart_sp_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 28 行 |
| player_skillfree | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 31 行 |
| player_skillup_limit | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 35 行 |
| quest_skill_learn | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 39 行 |
| quest_skill_reset | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 44 行 |
| basic_skill_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 47 行 |
| player_invincible_time | 3000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 54 行 |
| natural_healhp_interval | 6000 | 数值输入（枚举/单位须按说明确认） | NATURAL_HEAL_INTERVAL…INT_MAX | 已启用；源文件第 57 行 |
| natural_healsp_interval | 8000 | 数值输入（枚举/单位须按说明确认） | NATURAL_HEAL_INTERVAL…INT_MAX | 已启用；源文件第 60 行 |
| natural_heal_skill_interval | 10000 | 数值输入（枚举/单位须按说明确认） | NATURAL_HEAL_INTERVAL…INT_MAX | 已启用；源文件第 63 行 |
| natural_heal_weight_rate | 70 | 数值输入（枚举/单位须按说明确认） | 0…100；0…100 | 注释候选；源文件第 69 行 |
| open_box_weight_rate | 90 | 数值输入（枚举/单位须按说明确认） | 0…100；0…100 | 注释候选；源文件第 73 行 |
| major_overweight_rate | 90 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 77 行 |
| max_aspd | 190 | 数值输入（枚举/单位须按说明确认） | 100…199 | 已启用；源文件第 80 行 |
| max_third_aspd | 193 | 数值输入（枚举/单位须按说明确认） | 100…199 | 已启用；源文件第 83 行 |
| max_extended_aspd | 193 | 数值输入（枚举/单位须按说明确认） | 100…199 | 已启用；源文件第 86 行 |
| max_summoner_aspd | 193 | 数值输入（枚举/单位须按说明确认） | 100…199 | 已启用；源文件第 89 行 |
| max_walk_speed | 300 | 数值输入（枚举/单位须按说明确认） | 100…100*DEFAULT_WALK_SPEED | 已启用；源文件第 92 行 |
| max_hp_lv99 | 330000 | 数值输入（枚举/单位须按说明确认） | 100…1000000000 | 已启用；源文件第 98 行 |
| max_hp_lv150 | 660000 | 数值输入（枚举/单位须按说明确认） | 100…1000000000 | 已启用；源文件第 99 行 |
| max_hp | 1100000 | 数值输入（枚举/单位须按说明确认） | 100…1000000000 | 已启用；源文件第 100 行 |
| max_sp | 1000000 | 数值输入（枚举/单位须按说明确认） | 100…1000000000 | 已启用；源文件第 103 行 |
| max_parameter | 99 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 114 行 |
| max_trans_parameter | 99 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 115 行 |
| max_third_parameter | 130 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 116 行 |
| max_third_trans_parameter | 130 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 117 行 |
| max_baby_parameter | 80 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 118 行 |
| max_baby_third_parameter | 117 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 119 行 |
| max_extended_parameter | 130 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 120 行 |
| max_summoner_parameter | 130 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 121 行 |
| max_fourth_parameter | 130 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 122 行 |
| transcendent_status_points | 52 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 125 行 |
| max_def | 99 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 132 行 |
| over_def_bonus | 0 | 数值输入（枚举/单位须按说明确认） | 0…1000 | 已启用；源文件第 137 行 |
| max_cart_weight | 8000 | 数值输入（枚举/单位须按说明确认） | 100…1000000 | 已启用；源文件第 140 行 |
| prevent_logout | 10000 | 数值输入（枚举/单位须按说明确认） | 0…60000 | 已启用；源文件第 143 行 |
| prevent_logout_trigger | 14 | 数值输入（枚举/单位须按说明确认） | 0…0xF | 已启用；源文件第 152 行 |
| show_hp_sp_drain | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 155 行 |
| show_hp_sp_gain | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 158 行 |
| friend_auto_add | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 163 行 |
| invite_request_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 166 行 |
| bone_drop | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 174 行 |
| character_size | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2 | 已启用；源文件第 182 行 |
| idle_no_autoloot | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 187 行 |
| min_npc_vendchat_distance | 3 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 191 行 |
| rental_mount_speed_boost | 25 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 195 行 |
| vip_storage_increase | 300 | 数值输入（枚举/单位须按说明确认） | 0…MAX_STORAGE-MIN_STORAGE；0…MAX_STORAGE | 已启用；源文件第 204 行 |
| vip_base_exp_increase | 50 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 208 行 |
| vip_job_exp_increase | 50 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 212 行 |
| vip_exp_penalty_base | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 216 行 |
| vip_exp_penalty_job | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 217 行 |
| vip_zeny_penalty | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 222 行 |
| vip_bm_increase | 2 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 230 行 |
| vip_drop_increase | 50 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 236 行 |
| vip_gemstone | 2 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 243 行 |
| vip_disp_rate | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 246 行 |
| revive_onwarp | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 249 行 |
| taekwon_ranker_min_lv | 90 | 数值输入（枚举/单位须按说明确认） | 1…MAX_LEVEL | 已启用；源文件第 254 行 |
| fame_taekwon_mission | 1 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 258 行 |
| fame_refine_lv1 | 1 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX；0…INT_MAX | 已启用；源文件第 260 行 |
| fame_refine_lv2 | 25 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 261 行 |
| fame_refine_lv3 | 1000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 262 行 |
| fame_forge | 10 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 264 行 |
| blacksmith_fame_refine_threshold | 10 | 数值输入（枚举/单位须按说明确认） | 1…MAX_REFINE | 已启用；源文件第 266 行 |
| fame_pharmacy_3 | 1 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 268 行 |
| fame_pharmacy_5 | 3 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 269 行 |
| fame_pharmacy_7 | 10 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 270 行 |
| fame_pharmacy_10 | 50 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 271 行 |
| idletime_option | 0x7C1F | 数值输入（枚举/单位须按说明确认） | 1…0xFFFF | 已启用；源文件第 292 行 |
| summoner_race | 11 | 数值输入（枚举/单位须按说明确认） | RC_FORMLESS…RC_PLAYER_DORAM | 已启用；源文件第 297 行 |
| summoner_size | 0 | 数值输入（枚举/单位须按说明确认） | SZ_SMALL…SZ_BIG | 已启用；源文件第 298 行 |
| trait_points_job_change | 7 | 数值输入（枚举/单位须按说明确认） | 1…1000 | 已启用；源文件第 305 行 |
| max_trait_parameter | 110 | 数值输入（枚举/单位须按说明确认） | 10…SHRT_MAX | 已启用；源文件第 310 行 |
| max_res_mres_ignored | 50 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 314 行 |
| max_ap | 1000 | 数值输入（枚举/单位须按说明确认） | 100…1000000000 | 已启用；源文件第 318 行 |
| ap_rate | 100 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 321 行 |
| restart_ap_rate | 0 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 325 行 |
| loose_ap_on_death | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 329 行 |
| loose_ap_on_map | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 333 行 |
| keep_ap_on_logout | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 337 行 |

### battle/skill.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| casting_rate | 100 | 位掩码多选（按注释定义） | 0…INT_MAX | 已启用；源文件第 13 行 |
| delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 16 行 |
| delay_dependon_dex | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 20 行 |
| delay_dependon_agi | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 21 行 |
| min_skill_delay_limit | 100 | 数值输入（枚举/单位须按说明确认） | 10…INT_MAX | 已启用；源文件第 25 行 |
| amotion_min_skill_delay | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 35 行 |
| default_walk_delay | 300 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 41 行 |
| no_skill_delay | 2 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 48 行 |
| castrate_dex_scale | 150 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 51 行 |
| vcast_stat_scale | 530 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 54 行 |
| skill_amotion_leniency | 0 | 数值输入（枚举/单位须按说明确认） | 0…300 | 已启用；源文件第 61 行 |
| skill_delay_attack_enable | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 64 行 |
| skill_add_range | 0 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 69 行 |
| skill_out_range_consume | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 72 行 |
| skillrange_by_distance | 14 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 78 行 |
| skillrange_from_weapon | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 83 行 |
| skill_caster_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 88 行 |
| clear_skills_on_death | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 91 行 |
| clear_skills_on_warp | 15 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 94 行 |
| defunit_not_enemy | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 99 行 |
| skill_min_damage | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4 | 已启用；源文件第 108 行 |
| combo_delay_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 111 行 |
| auto_counter_type | 15 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 116 行 |
| skill_reiteration | 0 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 121 行 |
| skill_nofootset | 1 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 125 行 |
| gvg_traps_target_all | 1 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 129 行 |
| traps_setting | 0 | 数值输入（枚举/单位须按说明确认） | 0…2；0…2 | 注释候选；源文件第 136 行 |
| 1 | Enable players to damage the floras outside of versus grounds. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 139 行 |
| 2 | Enable players to damage marine spheres outside of versus grounds. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 140 行 |
| 4 | Disable having different types out at the same time | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 141 行 |
| 8 | Enable Marine Spheres to damage own Homunculus and summons outside PVP | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 144 行 |
| alchemist_summon_setting | 15 | 数值输入（枚举/单位须按说明确认） | 0…15；0…15 | 注释候选；源文件第 146 行 |
| skill_wall_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 151 行 |
| player_cloak_check_type | 1 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4 | 已启用；源文件第 162 行 |
| monster_cloak_check_type | 4 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4 | 已启用；源文件第 163 行 |
| land_skill_limit | 9 | 数值输入（枚举/单位须按说明确认） | BL_NUL…BL_ALL | 已启用；源文件第 166 行 |
| display_skill_fail | 2 | 数值输入（枚举/单位须按说明确认） | 0…1\|2\|4\|8 | 已启用；源文件第 173 行 |
| chat_warpportal | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 176 行 |
| 0 | Do not show defense | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 179 行 |
| 3 | Both (the addition of both) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 182 行 |
| sense_type | 1 | 数值输入（枚举/单位须按说明确认） | 0…1\|2 | 已启用；源文件第 183 行 |
| finger_offensive_type | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 188 行 |
| gx_allhit | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 198 行 |
| gx_disptype | 1 | 开关（0/1） | 0…1 | 已启用；源文件第 203 行 |
| devotion_level_difference | 10 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 206 行 |
| devotion_rdamage | 0 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 212 行 |
| devotion_rdamage_skill_only | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 216 行 |
| devotion_standup_fix | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 224 行 |
| player_skill_partner_check | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 227 行 |
| skill_removetrap_type | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 232 行 |
| backstab_bow_penalty | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 235 行 |
| skill_steal_max_tries | 0 | 数值输入（枚举/单位须按说明确认） | 0…UCHAR_MAX | 已启用；源文件第 240 行 |
| skill_steal_random_options | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 244 行 |
| max_heal | 9999 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 248 行 |
| max_heal_lv | 11 | 数值输入（枚举/单位须按说明确认） | 1…INT_MAX | 已启用；源文件第 249 行 |
| 16 | Disable skill from "nowarpto" maps | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 258 行 |
| emergency_call | 11 | 数值输入（枚举/单位须按说明确认） | 0…31 | 已启用；源文件第 260 行 |
| guild_aura | 31 | 数值输入（枚举/单位须按说明确认） | 0…31 | 已启用；源文件第 271 行 |
| mob_max_skilllvl | 100 | 数值输入（枚举/单位须按说明确认） | 1…MAX_MOBSKILL_LEVEL | 已启用；源文件第 275 行 |
| skip_teleport_lv1_menu | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 279 行 |
| allow_skill_without_day | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 282 行 |
| allow_es_magic_player | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 285 行 |
| sg_miracle_skill_ratio | 1 | 数值输入（枚举/单位须按说明确认） | 0…20000 | 已启用；源文件第 290 行 |
| sg_miracle_skill_duration | 3600000 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 293 行 |
| sg_angel_skill_ratio | 10 | 数值输入（枚举/单位须按说明确认） | 0…10000 | 已启用；源文件第 296 行 |
| 32 | Coluceo Heal, 64: Highness Heal, 128: Mediale Votum, 256: Dilectio Heal | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 300 行 |
| skill_add_heal_rate | 487 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 301 行 |
| eq_single_target_reflectable | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 306 行 |
| invincible.nodamage | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 311 行 |
| dancing_weaponswitch_fix | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 316 行 |
| skill_trap_type | 0 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 327 行 |
| multi_trigger_trap | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 333 行 |
| bowling_bash_area | 0 | 数值输入（枚举/单位须按说明确认） | 0…20 | 已启用；源文件第 340 行 |
| path_blown_halt | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 345 行 |
| taekwon_mission_mobname | 0 | 数值输入（枚举/单位须按说明确认） | 0…2 | 已启用；源文件第 352 行 |
| teleport_on_portal | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 356 行 |
| cart_revo_knockback | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 360 行 |
| arrow_shower_knockback | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 363 行 |
| stormgust_knockback | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 370 行 |
| default_fixed_castrate | 20 | 数值输入（枚举/单位须按说明确认） | 0…100 | 已启用；源文件第 376 行 |
| skill_eightpath_algorithm | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 385 行 |
| skill_eightpath_same_cell | yes | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 389 行 |
| can_damage_skill | 1 | 数值输入（枚举/单位须按说明确认） | 0…BL_ALL | 已启用；源文件第 396 行 |
| land_protector_behavior | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 404 行 |
| npc_emotion_behavior | 0 | 开关（0/1） | 0…1 | 已启用；源文件第 411 行 |
| tarotcard_equal_chance | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 417 行 |
| dispel_song | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 422 行 |
| refresh_song | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 426 行 |
| refresh_song_icon | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 432 行 |
| banana_bomb_duration | 0 | 数值输入（枚举/单位须按说明确认） | 0…UINT16_MAX | 已启用；源文件第 438 行 |
| skill_drop_items_full | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 443 行 |
| switch_remove_edp | 2 | 数值输入（枚举/单位须按说明确认） | 0…3 | 已启用；源文件第 451 行 |
| attack_machine_level_difference | 15 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 455 行 |
| oridecon_research_fix | no | 开关（编码保留原格式） | 0…1 | 已启用；源文件第 461 行 |

### battle/status.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| status_cast_cancel | 0 | 位掩码多选（按注释定义） | BL_NUL…BL_ALL | 已启用；源文件第 13 行 |
| debuff_on_logout | 0 | 数值输入（枚举/单位须按说明确认） | 0…1\|2 | 已启用；源文件第 20 行 |
| pc_status_def_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 25 行 |
| mob_status_def_rate | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 26 行 |
| pc_max_status_def | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 30 行 |
| mob_max_status_def | 100 | 数值输入（枚举/单位须按说明确认） | 0…INT_MAX | 已启用；源文件第 31 行 |

### char_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| userid | s1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 8 行 |
| passwd | p1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 9 行 |
| server_name | rAthena | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 15 行 |
| wisp_server_name | Server | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 18 行 |
| login_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 24 行 |
| bind_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 29 行 |
| login_port | 6900 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 32 行 |
| char_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 37 行 |
| char_port | 6121 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 40 行 |
| timestamp_format | [%d/%b %H:%M] | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 49 行 |
| stdout_with_ansisequence | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 52 行 |
| 1 | Log Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 55 行 |
| 2 | Log Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 56 行 |
| 4 | Log Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 57 行 |
| console_msg_log | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 60 行 |
| console_log_filepath | ./log/char-msg_log.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 63 行 |
| 8 | Hide Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 69 行 |
| 16 | Hide Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 70 行 |
| 32 | Hide Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 71 行 |
| console_silent | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 73 行 |
| console | off | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 78 行 |
| char_maintenance | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 84 行 |
| char_new | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 88 行 |
| char_new_display | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 91 行 |
| max_connect_user | -1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 95 行 |
| gm_allow_group | 99 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 101 行 |
| autosave_time | 60 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 105 行 |
| save_log | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 108 行 |
| start_point | iz_int,18,26:iz_int01,18,26:iz_int02,18,26:iz_int03,18,26:iz_int04,18,26 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 115 行 |
| start_point_pre | new_1-1,53,111:new_2-1,53,111:new_3-1,53,111:new_4-1,53,111:new_5-1,53,111 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 116 行 |
| start_point_doram | lasa_fild01,48,297 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 117 行 |
| start_items | 1201,1,2:2301,1,16:23484,1,0 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 124 行 |
| start_items_pre | 1201,1,2:2301,1,16 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 125 行 |
| start_items_doram | 1681,1,2:2301,1,16 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 126 行 |
| start_zeny | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 129 行 |
| fame_list_alchemist | 10 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 132 行 |
| fame_list_blacksmith | 10 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 133 行 |
| fame_list_taekwon | 10 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 134 行 |
| guild_exp_rate | 100 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 139 行 |
| unknown_char_name | Unknown | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 142 行 |
| log_char | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 145 行 |
| char_name_min_length | 4 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 149 行 |
| name_ignoring_case | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 153 行 |
| 0 | no restriction (default) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 157 行 |
| char_name_option | 1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 160 行 |
| char_name_letters | abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 164 行 |
| char_del_level | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 171 行 |
| char_del_delay | 86400 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 176 行 |
| 3 | Email address or Birthdate | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 183 行 |
| char_del_option | 2 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 188 行 |
| char_del_restriction | 3 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 195 行 |
| allowed_job_flag | 3 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 203 行 |
| clear_parties | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 206 行 |
| db_path | db | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 209 行 |
| pincode_enabled | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 217 行 |
| pincode_changetime | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 222 行 |
| pincode_maxtry | 3 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 226 行 |
| pincode_force | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 230 行 |
| pincode_allow_repeated | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 234 行 |
| pincode_allow_sequential | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 238 行 |
| char_move_enabled | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 247 行 |
| char_movetoused | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 252 行 |
| char_moves_unlimited | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 255 行 |
| char_rename_party | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 260 行 |
| char_rename_guild | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 264 行 |
| char_checkdb | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 267 行 |
| default_map | prontera | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 270 行 |
| default_map_x | 156 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 271 行 |
| default_map_y | 191 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 272 行 |
| clan_remove_inactive_days | 14 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 278 行 |
| mail_return_days | 15 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 287 行 |
| mail_delete_days | 15 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 293 行 |
| no | Only return attachments from read mail | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 296 行 |
| yes | Return attachments from all mail | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 297 行 |
| mail_retrieve | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 299 行 |
| mail_return_empty | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 303 行 |

### inter_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| log_inter | 1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 7 行 |
| inter_log_filename | log/inter.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 10 行 |
| party_share_level | 15 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 13 行 |
| start_status_points | 48 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 16 行 |
| emblem_woe_change | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 19 行 |
| emblem_transparency_limit | 80 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 22 行 |
| default_codepage |  | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 26 行 |
| login_server_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 34 行 |
| login_server_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 35 行 |
| login_server_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 36 行 |
| login_server_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 37 行 |
| login_server_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 38 行 |
| login_codepage |  | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 39 行 |
| login_case_sensitive | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 40 行 |
| ipban_db_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 42 行 |
| ipban_db_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 43 行 |
| ipban_db_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 44 行 |
| ipban_db_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 45 行 |
| ipban_db_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 46 行 |
| ipban_codepage |  | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 47 行 |
| char_server_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 50 行 |
| char_server_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 51 行 |
| char_server_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 52 行 |
| char_server_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 53 行 |
| char_server_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 54 行 |
| map_server_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 57 行 |
| map_server_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 58 行 |
| map_server_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 59 行 |
| map_server_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 60 行 |
| map_server_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 61 行 |
| web_server_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 64 行 |
| web_server_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 65 行 |
| web_server_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 66 行 |
| web_server_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 67 行 |
| web_server_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 68 行 |
| log_db_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 71 行 |
| log_db_port | 3306 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 72 行 |
| log_db_id | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 73 行 |
| log_db_pw | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 74 行 |
| log_db_db | ragnarok | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 75 行 |
| log_codepage |  | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 76 行 |
| log_login_db | loginlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 77 行 |
| 1 | When MySQL disconnects during runtime, the server tries to reconnect | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 81 行 |
| 2 | When mysql disconnects during runtime, it tries to reconnect indefinitely. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 83 行 |
| mysql_reconnect_type | 2 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 84 行 |
| mysql_reconnect_count | 1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 85 行 |
| login_server_account_db | login | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 94 行 |
| ipban_table | ipbanlist | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 95 行 |
| global_acc_reg_num_table | global_acc_reg_num | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 96 行 |
| global_acc_reg_str_table | global_acc_reg_str | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 97 行 |
| achievement_table | achievement | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 100 行 |
| char_db | char | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 101 行 |
| hotkey_db | hotkey | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 102 行 |
| scdata_db | sc_data | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 103 行 |
| cart_db | cart_inventory | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 104 行 |
| inventory_db | inventory | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 105 行 |
| charlog_db | charlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 106 行 |
| skill_db | skill | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 107 行 |
| interlog_db | interlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 108 行 |
| memo_db | memo | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 109 行 |
| guild_db | guild | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 110 行 |
| guild_alliance_db | guild_alliance | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 111 行 |
| guild_castle_db | guild_castle | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 112 行 |
| guild_expulsion_db | guild_expulsion | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 113 行 |
| guild_member_db | guild_member | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 114 行 |
| guild_skill_db | guild_skill | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 115 行 |
| guild_position_db | guild_position | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 116 行 |
| guild_storage_db | guild_storage | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 117 行 |
| party_db | party | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 118 行 |
| pet_db | pet | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 119 行 |
| friend_db | friends | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 120 行 |
| mail_db | mail | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 121 行 |
| mail_attachment_db | mail_attachments | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 122 行 |
| auction_db | auction | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 123 行 |
| quest_db | quest | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 124 行 |
| homunculus_db | homunculus | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 125 行 |
| skill_homunculus_db | skill_homunculus | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 126 行 |
| skillcooldown_homunculus_db | skillcooldown_homunculus | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 127 行 |
| mercenary_db | mercenary | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 128 行 |
| mercenary_owner_db | mercenary_owner | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 129 行 |
| skillcooldown_mercenary_db | skillcooldown_mercenary | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 130 行 |
| elemental_db | elemental | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 131 行 |
| skillcooldown_db | skillcooldown | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 132 行 |
| bonus_script_db | bonus_script | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 133 行 |
| acc_reg_num_table | acc_reg_num | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 134 行 |
| acc_reg_str_table | acc_reg_str | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 135 行 |
| char_reg_str_table | char_reg_str | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 136 行 |
| char_reg_num_table | char_reg_num | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 137 行 |
| clan_table | clan | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 138 行 |
| clan_alliance_table | clan_alliance | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 139 行 |
| barter_table | barter | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 142 行 |
| buyingstore_table | buyingstores | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 143 行 |
| buyingstore_items_table | buyingstore_items | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 144 行 |
| item_table | item_db | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 145 行 |
| item2_table | item_db2 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 147 行 |
| mob_table | mob_db | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 149 行 |
| mob2_table | mob_db2 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 151 行 |
| mob_skill_table | mob_skill_db | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 153 行 |
| mob_skill2_table | mob_skill_db2 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 155 行 |
| mapreg_table | mapreg | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 157 行 |
| partybookings_table | party_bookings | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 158 行 |
| sales_table | sales | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 159 行 |
| vending_table | vendings | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 160 行 |
| vending_items_table | vending_items | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 161 行 |
| market_table | market | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 162 行 |
| roulette_table | db_roulette | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 163 行 |
| guild_storage_log | guild_storage_log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 164 行 |
| guild_emblems | guild_emblems | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 169 行 |
| user_configs | user_configs | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 170 行 |
| char_configs | char_configs | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 171 行 |
| merchant_configs | merchant_configs | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 172 行 |
| use_sql_db | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 176 行 |
| inter_server_conf | inter_server.yml | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 178 行 |

### log_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| enable_logs | 0xFFFFFFFF | 位掩码多选（按注释定义） | 待核实 | 已启用；源文件第 44 行 |
| sql_logs | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 47 行 |
| log_filter | 1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 74 行 |
| refine_items_log | 5 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 77 行 |
| rare_items_log | 100 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 80 行 |
| price_items_log | 1000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 82 行 |
| amount_items_log | 100 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 84 行 |
| log_branch | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 88 行 |
| log_zeny | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 93 行 |
| log_cash | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 96 行 |
| log_mvpdrop | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 100 行 |
| log_commands | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 105 行 |
| log_npc | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 108 行 |
| log_chat | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 124 行 |
| log_chat_woe_disable | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 127 行 |
| 0 | Disabled | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 131 行 |
| 1 | Pet | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 132 行 |
| 2 | Homunculus | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 133 行 |
| log_feeding | 3 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 134 行 |
| log_timestamp_format | %m/%d/%Y %H:%M:%S | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 143 行 |
| log_gm_db | atcommandlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 159 行 |
| log_branch_db | branchlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 160 行 |
| log_chat_db | chatlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 161 行 |
| log_mvpdrop_db | mvplog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 162 行 |
| log_npc_db | npclog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 163 行 |
| log_pick_db | picklog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 164 行 |
| log_zeny_db | zenylog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 165 行 |
| log_cash_db | cashlog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 166 行 |
| log_feeding_db | feedinglog | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 167 行 |

### login_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| bind_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 11 行 |
| login_port | 6900 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 14 行 |
| timestamp_format | [%d/%b %H:%M] | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 23 行 |
| stdout_with_ansisequence | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 26 行 |
| 1 | Log Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 29 行 |
| 2 | Log Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 30 行 |
| 4 | Log Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 31 行 |
| console_msg_log | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 34 行 |
| console_log_filepath | ./log/login-msg_log.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 37 行 |
| 8 | Hide Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 43 行 |
| 16 | Hide Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 44 行 |
| 32 | Hide Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 45 行 |
| console_silent | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 47 行 |
| console | off | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 52 行 |
| new_account | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 56 行 |
| acc_name_min_length | 6 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 61 行 |
| password_min_length | 6 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 66 行 |
| allowed_regs | 1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 70 行 |
| time_allowed | 10 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 71 行 |
| login_log_filename | log/login.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 74 行 |
| log_login | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 78 行 |
| date_format | %Y-%m-%d %H:%M:%S | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 81 行 |
| group_id_to_connect | -1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 86 行 |
| min_group_id_to_connect | -1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 92 行 |
| vip_group | 5 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 96 行 |
| chars_per_account | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 102 行 |
| vip_char_increase | -1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 109 行 |
| start_limited_time | -1 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 114 行 |
| use_MD5_passwords | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 118 行 |
| usercount_disable | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 122 行 |
| usercount_low | 200 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 124 行 |
| usercount_medium | 500 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 126 行 |
| usercount_high | 1000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 128 行 |
| ipban_enable | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 131 行 |
| ipban_dynamic_pass_failure_ban | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 134 行 |
| ipban_dynamic_pass_failure_ban_interval | 5 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 136 行 |
| ipban_dynamic_pass_failure_ban_limit | 7 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 138 行 |
| ipban_dynamic_pass_failure_ban_duration | 5 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 140 行 |
| ipban_cleanup_interval | 60 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 144 行 |
| ip_sync_interval | 10 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 148 行 |
| use_dnsbl | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 153 行 |
| dnsbl_servers | bl.blocklist.de, socks.dnsbl.sorbs.net | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 154 行 |
| client_hash_check | off | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 170 行 |
| use_web_auth_token | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 174 行 |
| disable_webtoken_delay | 10000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 179 行 |
| client_hash | 0, 113e195e6c051bb1cfb12a644bb084c5 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 189 行 |

### map_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| userid | s1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 13 行 |
| passwd | p1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 14 行 |
| char_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 20 行 |
| bind_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 25 行 |
| char_port | 6121 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 28 行 |
| map_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 33 行 |
| map_port | 5121 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 36 行 |
| timestamp_format | [%d/%b %H:%M] | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 45 行 |
| stdout_with_ansisequence | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 48 行 |
| 1 | Log Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 51 行 |
| 2 | Log Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 52 行 |
| 4 | Log Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 53 行 |
| console_msg_log | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 56 行 |
| console_log_filepath | ./log/map-msg_log.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 59 行 |
| 8 | Hide Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 65 行 |
| 16 | Hide Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 66 行 |
| 32 | Hide Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 67 行 |
| console_silent | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 69 行 |
| db_path | db | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 72 行 |
| enable_spy | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 76 行 |
| use_grf | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 80 行 |
| console | off | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 85 行 |
| autosave_time | 300 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 91 行 |
| minsave_time | 100 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 96 行 |
| 64 | After successfully get/delete/complete a quest | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 106 行 |
| 128 | After every bank transaction (deposit/withdraw) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 107 行 |
| 256 | After every attendance reward | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 108 行 |
| 4095 | Always | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 109 行 |
| save_settings | 4095 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 114 行 |
| motd_txt | conf/motd.txt | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 117 行 |
| charhelp_txt | conf/charhelp.txt | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 120 行 |
| channel_conf | conf/channels.conf | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 123 行 |

### packet_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| debug | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 6 行 |
| epoll_maxevents | 1024 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 19 行 |
| stall_time | 60 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 22 行 |
| enable_ip_rules | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 28 行 |
| order | deny,allow | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 36 行 |
| allow | Accepts connections from the ip range (even if flagged as DDoS) | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 41 行 |
| deny | Rejects connections from the ip range | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 42 行 |
| ddos_interval | 3000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 58 行 |
| ddos_count | 5 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 62 行 |
| ddos_autoreset | 600000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 67 行 |

### script_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| warn_func_mismatch_paramnum | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 6 行 |
| check_cmdcount | 655360 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 8 行 |
| check_gotocount | 2048 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 10 行 |
| input_min_value | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 注释候选；源文件第 15 行 |
| input_max_value | 10000000 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 21 行 |
| warn_func_mismatch_argtypes | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 27 行 |

### subnet_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| subnet | 255.0.0.0:127.0.0.1:127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 7 行 |

### web_athena.conf

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| bind_ip | 127.0.0.1 | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 10 行 |
| web_port | 8888 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 13 行 |
| timestamp_format | [%d/%b %H:%M] | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 22 行 |
| stdout_with_ansisequence | no | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 25 行 |
| 1 | Log Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 28 行 |
| 2 | Log Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 29 行 |
| 4 | Log Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 30 行 |
| console_msg_log | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 33 行 |
| console_log_filepath | ./log/web-msg_log.log | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 36 行 |
| 8 | Hide Warning Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 42 行 |
| 16 | Hide Error and SQL Error messages. | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 43 行 |
| 32 | Hide Debug Messages | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 44 行 |
| console_silent | 0 | 数值输入（枚举/单位须按说明确认） | 待核实 | 已启用；源文件第 46 行 |
| print_req_res | off | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 51 行 |
| allow_gifs | yes | 开关（编码保留原格式） | 待核实 | 已启用；源文件第 54 行 |
| allowed_origin_cors |  | 文本/枚举/复合值（按说明确认） | 待核实 | 已启用；源文件第 65 行 |

### grf-files.txt

| 字段 | 仓库值 | 控件建议 | 源码范围 | 备注 |
|---|---|---|---|---|
| grf | C:\Program Files\Gravity\RO\rdata.grf | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 5 行 |
| data_dir | C:\Program Files\Gravity\RO\ | 文本/枚举/复合值（按说明确认） | 待核实 | 注释候选；源文件第 12 行 |

### 源码额外候选

`mob_skill_use`、`pet_hungry_friendly_decrease` 在 battle.cpp 注册，但 battle conf 未列出。核对用途后决定是否开放，不作为首版必做项。
