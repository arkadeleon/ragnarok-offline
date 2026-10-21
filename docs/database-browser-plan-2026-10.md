# 数据库浏览器改进计划

- 生成日期：2026-10-19
- 范围：`RagnarokOffline/Database/` 下的 7 个数据库（物品、职业、地图、怪物、宠物、技能、状态。召唤组原来是单独的数据库，已合并到物品和技能详情，见第 2 条），以及它们共用的组件：`ImageGrid`、`ImageGridCell`、`SectionHeaderView`、`SelectableButton`、`Stretchy`。

## 约定

- 条目按重要程度编号，从 1 开始依次往下做。
- 优先级
  - **P0**：影响能不能找到数据、看不看得懂。
  - **P1**：明显提高查找和阅读的效率。
  - **P2**：一致性和细节打磨。
  - **P3**：锦上添花。
- 一次只改一个点，改完停下来等 review。条目太大时拆成几次改。

## P0

### 1. 统一搜索规则（已完成）

- 原来的问题：
  - 只有物品、怪物、技能能用 `#ID` 搜索，而且这个功能是在各自的视图里分别实现的。
  - 大多只匹配 `displayName`。地图在宽屏布局里显示了内部名（比如 `prt_fild08`），但用内部名搜不到。
  - 每按一次键，都要在 MainActor 上把整个数组过滤一遍，没有 debounce。
- 最终方案：
  - 每个库在 `DatabaseModel` 里建一个 `DatabaseSearchIndex`。关键字在建索引时就折叠好（忽略大小写、变音符号和全角半角），匹配在 MainActor 之外进行。
  - 搜索输入有 200ms 的 debounce。
  - 各库的匹配范围：
    - 物品、怪物、技能：ID、本地化名、原名、Aegis 名。
    - 职业：本地化名、职业标识名。
    - 宠物：本地化名、怪物原名、Aegis 名。
    - 状态：本地化名、`SC_` 标识名。
    - 地图：本地化名、内部名。
    - 召唤组：组名。召唤组数据库后来删除了，这一项不再适用。
  - 只有物品、怪物、技能支持 ID 搜索。搜索词必须是纯数字，`#1002` 这种写法不算 ID 搜索。精确匹配到 ID 的记录排在结果最前面，其他按关键字匹配到的结果照常显示在后面。
  - `ItemDatabaseFilter` 和 `MonsterDatabaseFilter` 改成了 `Equatable` struct，只保存结构化的筛选条件。`searchText` 移到了视图里。

### 2. 补全详情数据

用户打开数据库主要就是为了查这些信息。按库拆成几次来改。

- 技能：
  - 增加每个等级的数据表：SP、施法时间、固定施法时间、延迟、冷却、射程。全为 0 的列不显示，6 列都为 0 时整个表不显示。负数射程显示为绝对值。（已完成）
  - 修正 `DatabaseModel.skills(for:)`：它读取 `jobs` 之前没有先调用 `fetchJobs()`。（已完成）
- 怪物：
  - 属性伤害倍率表，从 `attr_fix.yml` 取。（已完成）
  - 怪物技能列表，从 `mob_skill_db.txt` 取，显示等级和概率。技能、等级、概率都相同、只是状态不同的条目合并成一条。（已完成）
  - 负数 MobID 的全局技能（-1 所有 Boss，-2 所有普通怪，-3 所有怪）。现在的数据里没有，暂不处理。
- 物品：
  - "Dropped By" 按掉率从高到低排序。MVP 掉落和普通掉落分成两条显示。（已完成）
  - NPC 商店来源，从 `scriptCommands` 取，不显示浮动商店。（已完成）
  - 宠物用途：捕捉道具、宠物蛋、宠物装备、宠物食物。（已完成）
  - 商店详情页：（已完成）
    - 页头显示 NPC 精灵，标题是 NPC 名。
    - "Map" 显示所在地图和坐标，点击进入地图详情。
    - "Items" 列出这家店卖的所有商品和价格，点击进入物品详情。价格按商店类型显示单位：shop 显示 zeny，cashshop 显示 Cash。
    - "Sold By" 的点击跳转改为进入商店详情页。
    - 在小地图上标出商店的位置（`MapLocationView`）。
- 地图：
  - 传送点：列出能传送到的地图，按目标地图去重，不含同一张地图内部的传送点。（已完成）
  - mapflag：原样显示 flag 名和值，本地化留到第 3 条。按脚本顺序合并，`off` 会移除这个 flag 之前的全部条目。（已完成）
  - NPC：显示精灵、名字和坐标。隐藏规则和 rAthena 生成导航数据时一致。精灵的解析顺序和 rAthena 一致：数字 ID、`NPCJobID` 常量、怪物 AegisName，都不是时视为 `INVISIBLE`。（已完成）
- 召唤组：合并到物品和技能详情，删除了侧边栏的召唤组数据库。（已完成）
  - 物品脚本里有 `MOBG_<组名>` 的，物品详情显示"召唤 ›"。技能 SA_CLASSCHANGE 和 TK_MISSION 写死对应 CLASSCHANGE 和 TAEKWON_MISSION，和 rAthena 一致。
  - 详情里只预览前几只怪物，标题链接进入完整列表。完整列表不再单独显示默认怪物，而是把它排在第一位，加 Default badge。
  - 组名按大写匹配，因为 pre-renewal 的组名是大小写混写的。
  - 怪物详情不加"可由哪些道具召唤"的反向链接：Dead Branch 几乎包含所有普通怪物，意义不大。

### 3. 数值和标签的显示

- 现状：
  - 同一页里，有的字段用 `localizedName`（类型、种族），有的用 `stringValue`（体型、属性、弹药类型、卡片类型、技能类型）。结果是中文和英文枚举名混在一起。
  - Jobs、Classes、Locations、Race Groups、Modes 显示为 `"- xxx"` 换行的纯文本，内容是原始枚举名。
  - cell 副标题里的附加信息都写成括号文字：
    - 掉率 `(25%)`，以及 MVP 掉落标记 `(MVP)`。
    - 数量 `(5x)`。
    - 商店价格，比如 `Tool Dealer (50z)`。
    - 宠物物品用途 `(Tame Item)`、`(Egg Item)`、`(Equip Item)`、`(Food Item)`。
- 目标：
  - 所有字段统一显示本地化名称。怪物 AI 暂时保留编号；Race Groups 和 Modes 暂时只有英文；状态的 Status、Icon 是标识名，保留原样。（已完成）
  - 列表类字段改成 flow layout 的 tag。（已完成）
  - 上面这些括号文字统一改成语义色的胶囊 badge，不再用括号拼接字符串。以后新增的同类附加信息，也直接用 badge 显示。（已完成）
    - 按信息类型着色，同一类信息用同一种颜色，和数值大小无关。掉率、MVP、数量、价格各用一种颜色。
    - 宠物物品用途按种类各用一种颜色。

### 4. 像素图插值（已完成）

- 原来的问题：工程里没有一处用 `.interpolation(.none)`，放大的像素图边缘发糊。
- 最终方案：
  - 物品图标、技能图标、状态图标（原图 24×24，显示为 40pt）和物品预览图（显示高度 200pt）使用 `.interpolation(.none)`。
  - 地图图片不改：小图是 60px 的缩略图，大图原图一般是 512px，显示时都不是像素放大。
  - 怪物精灵在 `MonsterImageView` 里只会缩小，不受影响。

## P1

### 5. 宽屏列表的表头和排序（暂缓）

- 现状：物品、技能、地图在 regular 布局下用 `HStack` 固定列宽，没有表头，也不能排序。
- 不用 `Table`：`Table` 的单元格里不能可靠地使用 `NavigationLink`，要改成绑定 `NavigationStack` 的 path、用 `primaryAction` 推入页面，改动太大。
- 备选方案：继续用 `List`，表头和行共用一个行布局；工具栏加排序菜单。要注意 iOS 上 `NavigationLink` 右边的箭头会让行比表头窄。
- 暂时不做。

### 6. 补充筛选项

- 新增筛选维度：（已完成）
  - 怪物：等级范围（最小、最大输入框）、Class 单选、MVP 开关。
  - 物品：选了 Weapon、Armor、Shadowgear 时显示槽位数、可装备职业、装备等级。装备等级填角色的 Base Level，只保留这个等级能装备的物品。
  - 技能：新增筛选页，可以按 Type 和 Target Type 筛选。不按职业筛选，职业的技能可以在职业详情页查。
- 交互改进：（已完成）
  - 有筛选生效时，工具栏的筛选按钮显示为选中状态：用 `.toggleStyle(.button)` 的 Toggle，开关绑定 `!filter.isEmpty`，点击只打开筛选页。
  - 单选项（类型、体型、种族、属性）再点一次可以取消，筛选条件上加了 `toggleXXX` 方法。
  - "No Results" 页面在有筛选生效时显示 Reset Filters 按钮。

### 7. 信息分组和语义色（已完成）

- 怪物属性分成 Info、Stats、Actions 三组。物品不分组。
- 属性值加上单位，格式统一放在 `DatabaseFormatting.swift`：
  - `formatTime`：毫秒，h/m/s/ms，narrow。怪物 Actions 组只用毫秒。
  - `formatCells`：`^[%lld cell](inflect: true)`。
  - `formatRate`：百分比，`base` 表示 100%。
  - `formatZeny`、`formatWeight`。
- 数字一律不用等宽，只有脚本相关（Script、Map Flags）用等宽字体。
- 怪物的 Element 和 Element Level 合并成一行，比如 "Fire 2"。元素颜色和 Class 都不上色。
- 属性网格的列宽保持 `adaptive(minimum: 280)`。

### 8. 列表副标题和网格标记（暂缓）

- 现状：
  - compact 布局的副标题显示的是 `aegisName`（`ItemCell`、`SkillCell`）。
  - `StatusChangeCell` 没有副标题，行高和其他 cell 不一样。
  - 怪物网格只显示名字。
- 目标：
  - 副标题改成有用的摘要。比如物品显示"武器 · 短剑 · 50z"，技能显示"Lv.10 · 主动"。
  - 怪物网格加上等级、MVP 标记和属性色点。

## P2

### 9. 统一详情页头（暂缓）

- 现状：
  - 技能和状态的详情页没有 hero 区。
  - 职业详情显示静态首帧，怪物详情显示动画。
  - "加载中"和"没有图片"显示的是同一个细线 SF Symbol，分不出来。
  - hero 区高 200pt，背景空白，小精灵放在里面显得很空。
- 目标：
  - 所有库都用同一种页头：大图或图标 + 名字 + `#ID`。
  - 加载中显示占位，和"没有图片"区分开。
  - 在精灵下面加一层淡渐变底或地面阴影。

### 10. 职业等级表（已完成）

- 原来的问题：用 `HStack` 把四列等分，其中一列用空的 `Text(verbatim: "")` 占位；175 行全部展开在职业详情页里，往下滚就看不到表头了。
- 最终方案：
  - 完整的表格移到两个单独的页面：`BaseLevelTableView`（Base Level、Base Exp、Base HP、Base SP）和 `JobLevelTableView`（Job Level、Job Exp、Bonus Stats）。表头用 `LazyVStack(pinnedViews: [.sectionHeaders])` 吸顶，行有斑马纹，去掉了空列。没有改用 `Grid`，因为 `Grid` 不是 lazy 的，而等分的列本来就对齐。
  - 职业详情页在 Skills 之前放 "Base Levels ›" 和 "Job Levels ›" 两个 section，标题是进入完整表格的链接，内容是前 10 级的预览，显示成 "Level 1　Exp 100"，没有表头和斑马纹。

### 11. 交互反馈（已完成）

- 筛选页的 `SelectableButton`：选中时用 `.borderedProminent`，没选中时用 `.bordered` 加次要色。
- 网格 cell 的 hover 和按下效果：不做。

### 12. Pre-renewal 模式

- 现状：`App/AppModel.swift:48` 写死了 `DatabaseModel(mode: .renewal, ...)`。`MonsterModel` 等模型已经实现了 pre-renewal 分支，比如最小和最大攻击，但现在用不到。
- 目标：提供模式切换（放在设置里，或放在数据库工具栏上），切换后重新加载数据库。

## P3

### 13. 复制 ID 和 Aegis 名

- 属性值支持选中复制，或者通过右键菜单复制 ID 和 Aegis 名。

## 收尾

全部条目完成后，评估是否需要整理代码，比如抽出通用的 `DatabaseListView`，合并重复的 `GridItem(.adaptive(minimum: 280))`。
