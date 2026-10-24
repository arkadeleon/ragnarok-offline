# 数据库浏览器改进计划

- 生成日期：2026-10-19，2026-10-21 清理为新增数据的 5 条，2026-10-23 第 2 条完成，2026-10-24 第 3 条完成。
- 范围：在 `RagnarokOffline/Database/` 的数据库里展示 rAthena 中还没用到的数据。pre-renewal 也有对应的文件（`create_arrow_db.yml` 两种模式共用一份）。

## 约定

- 条目从 1 开始依次往下做。第 1 条试过不好做，先跳过。
- 一次只改一个点，改完停下来等 review。条目太大时拆成几次改。
- rAthena 的 YAML 按文档逐字段解析，字段注释照抄文档原文。枚举值用 RagnarokOfflineGenerator 从 rAthena 源码转换，不手写。
- 导航一律按值推送（`NavigationLink(value:)`），destination 注册在 `ContentView.navigationDestinations`。只有不再往下跳的末端页面才能按 view 推送。
- 关联列表的 section 只预览前 9 个（`previewXXX`），标题带箭头链接到完整列表。"Obtains"、"Summon"、"Obtained From"、"Combos" 总是显示箭头，"Dropped By" 超过 9 个才显示（`hasMoreDropSources`）。
- 反向查询不要在打开详情页时扫描全部数据，要在加载数据时一起算好。需要同时用到两份数据的纯计算放进 `RagnarokDatabase`，在后台跑，比如 `ItemGroupDatabase.sourceItemIDs(in:)`。
- Badge 是数据：`DatabaseBadge` 只有 `text` 和 `semantic`，颜色由 `DatabaseBadgeView` 按 `semantic` 决定。关联类型自己提供 `badges`，cell 统一接收 `badges:`（`ItemCell`、`SkillCell`、`MapCell`、`NPCGridCell`、`ImageGridCell`），不再为了 badge 单独写 cell。新的 badge 加一个 `Semantic` 和一个工厂方法，都按字母顺序排。

## 1. 技能的物品消耗（暂缓）

- 数据：`skill_db.yml` 的 `Requires.ItemCost`，`RagnarokDatabase` 已经解析成 `Skill.Requires.itemCost`，只是没有展示。
- 展示：技能详情加一个 section，列出消耗的物品和数量，点击进入物品详情。带 `Level` 的条目只在对应等级生效，要标出等级。
- 反向：物品详情显示"被哪些技能消耗"，比如蓝色魔力矿石。

## 2. 箱子内容（`item_group_db.yml`）（完成）

- 数据：renewal 2996 个物品组，pre-renewal 62 个。每组分 SubGroup，每个 SubGroup 独立抽取一次：`All` 全给，`Random` 按 rate 抽 1 个，`SharedPool`（默认）抽 1 个并从池子里扣掉。
- 关联：物品脚本里的 `getgroupitem(IG_<组名>)`，脚本里没有其他调用方式。renewal 有 2 个组在数据里不存在（`FPR_RESET_STONE_BOX`、`R_EP1921_BOSS`），对不上。
- 已实现：
  - 解析：`RagnarokDatabase` 的 `ItemGroup` / `ItemGroupDatabase`。生成的枚举有 `ItemGroupAlgorithm`、`ItemBound`、`EnchantGrade`。
  - 模型：`ItemGroupModel` 加载时就记下调用这个组的物品（`sourceItems`，由后台的 `ItemGroupDatabase.sourceItemIDs(in:)` 算出）。每条记录和它的概率是 `ItemGroupModel.SubGroupListItemChance`，`ObtainableItem` 和 `ItemModel.ObtainSource` 都包含它。
  - 物品详情 "Obtains" section：预览能开出的物品，概率是 rate 除以同一个 SubGroup 的 rate 总和，`All` 的物品显示 100%，数量大于 1 时显示数量。完整列表页 `ItemGroupDetailView` 按 SubGroup 分段，标题带规则名，比如 "SubGroup 0 (All)"。
  - 物品详情 "Obtained From" section：预览能开出这个物品的箱子（`ItemModel.ObtainSource`），同一个箱子的多个 SubGroup 里都有时只显示概率最高的一次。完整列表页 `ItemGroupsContainingItemView` 先按物品组分段（标题链接到组的详情），再按 SubGroup 分段。
- 顺带完成：
  - "Dropped By" 改成预览加完整列表页 `MonstersDroppingItemView`。
  - Summon 改成按值推送。
  - 关联类型改名：`DropSource`、`SpawnMonster`、`CastSkill`、`ObtainSource`，以及 `shops(for:)`、`petUsages(forItemAegisName:)`、`castSkills(for:)`、`obtainSources(forItemAegisName:)`。关联类型都嵌套进了它显示的那一侧的模型，比如 `ItemModel.DropSource`、`MonsterModel.SpawnMap`。
  - 所有 badge 改成 `DatabaseBadge` 数据，删掉了 `XxxBadge` view 和只为 badge 存在的 cell（`DropSourceGridCell`、`MonsterSummonGridCell`、`ItemGroupObtainableItemCell`、`ItemGroupSourceCell`）。

## 3. 套装（`item_combos.yml`）（完成）

- 数据：renewal 5114 个条目、8618 个 Combo，pre-renewal 105 个条目、156 个 Combo。一个 Combo 就是一个套装，要同时穿齐。一个条目里的几个 Combo 共用同一段 Script，各自独立生效，展示时以 Combo 为单位，不管条目。
- 已实现：
  - 解析：`RagnarokDatabase` 的 `ItemCombo` / `ItemComboDatabase`。
  - 模型：`ItemModel.ItemCombo` 是一个 Combo（物品和所在条目的脚本），id 是它在所有 Combo 里的序号。`DatabaseModel.fetchItemCombos()` 加载时就建好按物品 AegisName 的反向索引 `itemCombosByItemAegisName`。
  - 物品详情 "Combos" section：标题总是显示箭头，只预览第 1 个 Combo，列出它的全部物品（包括当前物品），脚本放在 "Script" subsection。内容由 `ItemComboView` 显示。
  - 完整列表页 `ItemCombosContainingItemView`：每个 Combo 一个 section，标题是 "Combo 1"、"Combo 2"……，内容和预览一样。

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
