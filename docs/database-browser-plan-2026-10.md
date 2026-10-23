# 数据库浏览器改进计划

- 生成日期：2026-10-19，2026-10-21 清理为新增数据的 5 条，2026-10-23 第 2 条完成。
- 范围：在 `RagnarokOffline/Database/` 的数据库里展示 rAthena 中还没用到的数据。pre-renewal 也有对应的文件（`create_arrow_db.yml` 两种模式共用一份）。

## 约定

- 条目从 1 开始依次往下做。第 1 条试过不好做，先跳过。
- 一次只改一个点，改完停下来等 review。条目太大时拆成几次改。
- rAthena 的 YAML 按文档逐字段解析，字段注释照抄文档原文。枚举值用 RagnarokOfflineGenerator 从 rAthena 源码转换，不手写。
- 导航一律按值推送（`NavigationLink(value:)`），destination 注册在 `ContentView.navigationDestinations`。只有不再往下跳的末端页面才能按 view 推送。
- 关联列表的 section 只预览前 9 个（`previewXXX`），超过 9 个才在标题显示箭头、链接到完整列表（`hasMoreXXX`）。
- 反向查询不要在打开详情页时扫描全部数据，要在加载数据时一起算好。

## 1. 技能的物品消耗（暂缓）

- 数据：`skill_db.yml` 的 `Requires.ItemCost`，`RagnarokDatabase` 已经解析成 `Skill.Requires.itemCost`，只是没有展示。
- 展示：技能详情加一个 section，列出消耗的物品和数量，点击进入物品详情。带 `Level` 的条目只在对应等级生效，要标出等级。
- 反向：物品详情显示"被哪些技能消耗"，比如蓝色魔力矿石。

## 2. 箱子内容（`item_group_db.yml`）（完成）

- 数据：renewal 2996 个物品组，pre-renewal 62 个。每组分 SubGroup，每个 SubGroup 独立抽取一次：`All` 全给，`Random` 按 rate 抽 1 个，`SharedPool`（默认）抽 1 个并从池子里扣掉。
- 关联：物品脚本里的 `getgroupitem(IG_<组名>)`，脚本里没有其他调用方式。renewal 有 2 个组在数据里不存在（`FPR_RESET_STONE_BOX`、`R_EP1921_BOSS`），对不上。
- 已实现：
  - 解析：`RagnarokDatabase` 的 `ItemGroup` / `ItemGroupDatabase`。生成的枚举有 `ItemGroupAlgorithm`、`ItemBound`、`EnchantGrade`。
  - 模型：`ItemGroupModel` 加载时就记下调用这个组的物品（`sourceItems`）。
  - 物品详情 "Obtains" section：预览能开出的物品，概率是 rate 除以同一个 SubGroup 的 rate 总和，`All` 的物品显示 100%，数量大于 1 时显示数量。完整列表页 `ItemGroupDetailView` 按 SubGroup 分段，标题带规则名，比如 "SubGroup 0 (All)"。
  - 物品详情 "Obtained From" section：列出能开出这个物品的箱子（`ItemGroupSource`）。同一个箱子的多个 SubGroup 里都有时，只显示概率最高的一次。
- 顺带完成：
  - "Dropped By" 改成预览加完整列表页 `MonstersDroppingItemView`。
  - Summon 改成按值推送。
  - 关联类型改名：`DropSource`、`SpawnMonster`，以及 `shops(for:)`、`petUsages(forItemAegisName:)`。

## 3. 套装（`item_combos.yml`）

- 数据：5115 组套装，每组列出组成的物品（AegisName）和套装效果脚本。
- 展示：物品详情加 "Combos" section，每个套装列出同套的其他物品（点击进入物品详情）和效果脚本（等宽字体，和 Script 一致）。

## 4. 物品制作（`produce_db.txt`、`create_arrow_db.yml`）

- 数据：
  - `produce_db.txt`：锻造、制药、烹饪等配方，每条有产物、需要的技能和等级、材料和数量。数量为 0 表示只需要带在身上，比如制作指南。
  - `create_arrow_db.yml`：制箭，用一个物品做成若干支箭。
- 展示：
  - 物品详情显示"制作方法"：需要的技能（点击进入技能详情）和材料。
  - 物品详情反向显示"可用于制作"：用这个物品当材料的产物。

## 5. 任务（`quest_db.yml`）

- 数据：renewal 4821 个任务、pre-renewal 2879 个。每个任务有标题、时限、要打的怪（Targets）和任务掉落（Drops）。
- 展示：
  - 新增一个任务库，可以按标题和 ID 搜索。任务详情显示时限、目标怪物和数量、任务掉落。
  - 怪物详情反向显示相关任务，物品详情显示作为任务掉落的来源。
