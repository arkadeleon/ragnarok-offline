# NPC 商店（买 / 卖）实施计划

## 已确认的现状

- 生成好的封包（`Packages/RagnarokPackets/.../Generated/packets.swift`）：`PACKET_ZC_SELECT_DEALTYPE`(npcId)、`PACKET_ZC_PC_PURCHASE_ITEMLIST`(items: itemId/price/discountPrice/itemType/viewSprite/location)、`PACKET_ZC_PC_SELL_ITEMLIST`(items: index/price/overcharge)、`PACKET_ZC_PC_PURCHASE_RESULT`(result)、`PACKET_CZ_ACK_SELECT_DEALTYPE`(GID/type)、`PACKET_CZ_PC_PURCHASE_ITEMLIST`(items: amount/itemId)、`PACKET_CZ_PC_SELL_ITEMLIST`(sellList: index/amount)。ZC 三个已在 `PacketRegistry.swift` 注册。
- **缺失**（rAthena 用裸 WFIFO 写，没生成）：`ZC_PC_SELL_RESULT`(0xcb, result.B) —— `PacketRegistry.swift:223` 是注释掉的；`CZ_NPC_TRADE_QUIT`(0x9d4, 长度 2, `clif_parse_NPCShopClosed`) 只在 `packetdb.swift:1210` 有条目，没有 struct；`HEADER_CZ_PC_PURCHASE_ITEMLIST`(0xc8) 没有常量（`packetdb.swift:70` 用字面量）。这些按现有手写封包惯例补（`Packets/ZC/PACKET_ZC_NOTIFY_EXP.swift`、`Packets/CZ/PACKET_CZ_REQ_NEXT_SCRIPT.swift` 的样式），不需要跑 `./generate.sh`。
- 服务器流程（`swift-rathena/src/map/npc.cpp:2242,2387`、`clif.cpp:12299,12347`）：点商店 NPC 或脚本 `callshop` → `ZC_SELECT_DEALTYPE` → 客户端回 `CZ_ACK_SELECT_DEALTYPE`(type 0 买 / 1 卖) → `ZC_PC_PURCHASE_ITEMLIST` 或 `ZC_PC_SELL_ITEMLIST` → 客户端回 `CZ_PC_PURCHASE_ITEMLIST` / `CZ_PC_SELL_ITEMLIST` → 服务器清 `npc_shopid` 并回 `ZC_PC_PURCHASE_RESULT` / `ZC_PC_SELL_RESULT`。买到的物品走已处理的 `ZC_ITEM_PICKUP_ACK`，卖掉的走已处理的 `ZC_DELETE_ITEM_FROM_BODY`/`ZC_ITEM_THROW_ACK`，zeny 走已处理的 `ZC_PAR_CHANGE`。
- roBrowserLegacy 行为要点：
  - 选类型弹窗用 msg 92「Please select a Deal Type.」+ Buy / Sell / Cancel；Cancel 不发包，只关窗。
  - 商店窗口关闭（未成交）时发 `CZ_NPC_TRADE_QUIT`（PACKETVER ≥ 20131223，本项目 `PACKET_VERSION = 20211103`）。收到结果包后关窗不再发。
  - 买：加入购物车时若 `已选总价 + 单价×数量 > zeny` 拒绝并提示 msg 55；单价取 `discountPrice`，为 0 时取 `price`。
  - 卖：列表按 `index` 回查背包取图标/名称/数量，数量上限为背包持有量；单价取 `overcharge`，为 0 时取 `price`。
  - 结果消息：买 0→54，1→55，2→56，4→230，5→281，7→1797，其它→57；卖 0→54，其它→57。这些 ID 在 `en.lproj/MessageString.json` 里都存在。
  - 标题 msg：买 186「Shop Items」/ 166「Buying Items」；卖 185「Available Items to sell」/ 168「Selling Items」。
- 现有可复用模式：`WarpList` + `WarpListView` + `GameSession.warpList`/`selectWarpPoint` 是"服务器推一个列表 → 独立窗口 → 回包 → 清空"的完整先例；`NPCDialog` 的 `update(from:)` 风格；`MessageCenter.addMessage(for:)`；`MessageBoxView` 做选类型弹窗；`InventoryView` 的 `InventoryItemView` 图标加载（`gameContext.resourceManager.itemIconImage(forItemID:)`）与 `contextMenu` 弹层样式；`PacketFactory` 变长包写法（`CZ_INPUT_EDITDLGSTR` 手算 `packetLength`）。

## 实施步骤

### 1. RagnarokPackets：补三个手写封包

- 新建 `Packages/RagnarokPackets/Sources/RagnarokPackets/Packets/ZC/PACKET_ZC_PC_SELL_RESULT.swift`：`HEADER_ZC_PC_SELL_RESULT: Int16 = 0xcb`，`DecodablePacket`，字段 `packetType`、`result: UInt8`。在 `PacketRegistry.swift:223` 取消注释注册。
- 新建 `Packets/CZ/PACKET_CZ_NPC_TRADE_QUIT.swift`：`HEADER_CZ_NPC_TRADE_QUIT: Int16 = 0x9d4`，`EncodablePacket`，只编码 `packetType`。
- `HEADER_CZ_PC_PURCHASE_ITEMLIST` 不补常量，第 2 步 `PacketFactory` 里直接 hardcode `0xc8`（struct 已生成）。
- `PacketRegistryTests` 是注册数量断言，新注册 0xcb 后把 384 改成 385。

### 2. RagnarokNetwork：`PacketFactory` 加四个构造

在 `PacketFactory.swift` NPC 段（`CZ_CONTACTNPC` 附近）加：
- `CZ_ACK_SELECT_DEALTYPE(npcID:dealType:)` → GID/type。
- `CZ_PC_PURCHASE_ITEMLIST(purchases: [NPCShopPurchase])` → `packetType = 0xc8`，`packetLength = 4 + purchases.count * PACKET_CZ_PC_PURCHASE_ITEMLIST_sub.size`。
- `CZ_PC_SELL_ITEMLIST(sales: [NPCShopSale])` → 同上，`packetType = HEADER_CZ_PC_SELL_ITEMLIST`。
- `CZ_NPC_TRADE_QUIT()`。

参数类型用第 3 步的模型（`NPCShopPurchase` / `NPCShopSale`）而不是元组，和 `CZ_SHORTCUT_KEY_CHANGE2(change: ShortcutChange)` 的做法一致，所以第 3 步的模型随第 2 步一起建。

### 3. RagnarokModels：Core Model

新建 `Packages/RagnarokModels/Sources/RagnarokModels/NPCShop.swift`（仿 `WarpList.swift`），各类型都带 memberwise `init` 和 `init(from:)`：

```swift
public enum NPCShopDealType: UInt8, Sendable { case buy = 0, sell = 1 }

public struct NPCShopBuyItem: Sendable, Hashable {
    public let itemID: Int, price: Int, discountPrice: Int, type: ItemType, location: EquipPositions
    public var unitPrice: Int { discountPrice > 0 ? discountPrice : price }   // roBrowser: discountprice || price
}

public struct NPCShopSellItem: Sendable, Hashable {
    public let index: Int, price: Int, overcharge: Int
    public var unitPrice: Int { overcharge > 0 ? overcharge : price }        // roBrowser: overchargeprice || price
}

public enum NPCShop: Equatable, Sendable {
    case buy([NPCShopBuyItem])   // init(from: PACKET_ZC_PC_PURCHASE_ITEMLIST)
    case sell([NPCShopSellItem]) // init(from: PACKET_ZC_PC_SELL_ITEMLIST)
}

public struct NPCShopPurchase: Sendable { public let itemID: Int; public let amount: Int }
public struct NPCShopSale: Sendable { public let index: Int; public let amount: Int }
```

选类型阶段只需要 npcID，直接在 `GameSession` 上放 `var dealSelectionNPCID: UInt32?`，不另建模型。

### 4. RagnarokGame：`GameSession` 状态与收发

`Engine/GameSession.swift`：
- 属性（`warpList` 旁）：`var dealSelectionNPCID: UInt32?`、`var npcShop: NPCShop?`。
- `handleMapPacket` 加分支（放在 NPC 对话那组附近）：
  - `PACKET_ZC_SELECT_DEALTYPE` → `dealSelectionNPCID = packet.npcId`
  - `PACKET_ZC_PC_PURCHASE_ITEMLIST` → `npcShop = .buy(...)`
  - `PACKET_ZC_PC_SELL_ITEMLIST` → `npcShop = .sell(...)`
  - `PACKET_ZC_PC_PURCHASE_RESULT` → `npcShop = nil`；`context.messageCenter.addMessage(for: packet)`
  - `PACKET_ZC_PC_SELL_RESULT` → 同上
- `// MARK: - NPC` 段新增方法：
  - `selectDealType(_ type: NPCShopDealType)`：guard `dealSelectionNPCID`，发 `CZ_ACK_SELECT_DEALTYPE`，清 `dealSelectionNPCID`。
  - `cancelDealSelection()`：只清 `dealSelectionNPCID`（roBrowser 不发包）。
  - `purchaseItems(_ purchases: [NPCShopPurchase])` / `sellItems(_ sales: [NPCShopSale])`：发对应包；不清 `npcShop`，等结果包再关（与 roBrowser 一致，结果包决定关窗与提示）。
  - `closeNPCShop()`：`npcShop = nil` 并发 `CZ_NPC_TRADE_QUIT`。
- `exitCurrentPhase()` / 换图时不必特殊处理：`npcShop` 是普通可选属性，随 `.map` 阶段退出时一并清掉即可（在 `case .map:` 里顺手置 nil，`dialog`/`warpList` 目前也没清，可一起补）。

`Core/Models/MessageCenter.swift` 的 `// MARK: - Item` 段加：
- `addMessage(for packet: PACKET_ZC_PC_PURCHASE_RESULT)`：按上面的 result→msgID 映射，0 为 `.system`，其余 `.error`，category `.item`。
- `addMessage(for packet: PACKET_ZC_PC_SELL_RESULT)`：0→54 `.system`，其它→57 `.error`。
- 买入时客户端拒绝加购（zeny 不足）也复用 55，加一个 `addInsufficientZenyMessage()` 或直接用 `Message(content:type:category:)` 构造。

### 5. RagnarokGame：UI

**`UI/NPCShopDealTypeView.swift`（新建，小）**：基于 `MessageBoxView(msg 92)`，bottomBar 三个 `.buttonStyle(.game)` 按钮 Buy / Sell / Cancel（尺寸同 `WarpListView` 的 42×20），分别调用 `gameSession.selectDealType(.buy / .sell)`、`cancelDealSelection()`。

**`UI/NPCShopView.swift`（新建，主窗口）**，`var shop: NPCShop`，`@Environment(GameSession.self)`、`@Environment(GameContext.self)`：
- 布局：`GameWindow`，宽 280（与 NPC 对话/传送列表一致），`GameTitleBar(closeAction: gameSession.closeNPCShop)`。内容自上而下：
  1. 标题行（msg 186 / 185）+ 商品列表 `ScrollView`（高约 130，参考 `NPCDialogMessageBox`）。每行：32×32 图标（`resourceManager.itemIconImage(forItemID:)`，写成 file-private 的 `NPCShopItemRow`）、名称（`itemInfoTable.localizedIdentifiedItemName(forItemID:)`，缺省显示 ID）、单价「N Zeny」；卖出模式额外显示背包持有数量。
  2. 标题行（msg 166 / 168）+ 购物车列表（高约 80，参考 `WarpListBox`），每行：图标、名称、`数量 × 单价`。
  3. 合计行：「Total : N Zeny」+ 当前持有 zeny（`gameContext.playerStatus.zeny`）。
- 交互（移动端不做拖拽，用点按）：
  - 点商品行 → 弹出数量输入层（复用 `InventoryView.contextMenu` 那种 `Material.bar` 圆角弹层 + `matchedGeometryEffect` 的样式；含 `-` / 数字 `TextField`(numberPad) / `+` / 「Add」），确认后写入 `@State cart: [Int: Int]`（key：买=itemID，卖=inventory index）。
  - 卖出模式上限 = `gameContext.inventory.items[index]?.amount`；买入模式无上限，但 `total + unit × count > zeny` 时拒绝并走 msg 55（与 roBrowser 一致）。
  - 点购物车行 → 从购物车移除（或减一，选其一即可，roBrowser 是拖回去减任意数量，这里做「移除」）。
- bottomBar：`GameBottomBar` 里「Buy」/「Sell」（购物车为空时 disabled）+「Cancel」→ `closeNPCShop()`。提交时把 `cart` 映射为 `[NPCShopPurchase]` / `[NPCShopSale]`。
- `.onChange(of: shop)` 时清空 `cart`（同 `WarpListView.onChange(of: warpList.mapNames)`）。给 `NPCShop` 加 `Equatable`。
- 卖出列表过滤：`index` 在 `gameContext.inventory.items` 中找不到的条目不显示（roBrowser `setList` SELL 分支同样跳过）。
- `#Preview`：用 `GameSession.testing` / `GameContext.testing`，构造 `.buy([...501/502/1101...])` 和 `.sell` 两个预览。

**`UI/MapSceneView.swift`**：在 `dialog` / `warpList` 那个 `.overlay(alignment: .center)` 里追加：
```swift
if let npcShop = gameSession.npcShop { NPCShopView(shop: npcShop) }
if let npcID = gameSession.dealSelectionNPCID { NPCShopDealTypeView() }
```
顺序放在 `NPCDialogView` 之后，保证 `callshop` 时商店盖在对话框上。

## 关键文件

- 改：`Packages/RagnarokPackets/Sources/RagnarokPackets/PacketRegistry.swift`（取消注释 0xcb）、`Tests/RagnarokPacketsTests/PacketRegistryTests.swift`（384 → 385）
- 新：`Packages/RagnarokPackets/.../Packets/ZC/PACKET_ZC_PC_SELL_RESULT.swift`、`Packets/CZ/PACKET_CZ_NPC_TRADE_QUIT.swift`
- 改：`Packages/RagnarokNetwork/Sources/RagnarokNetwork/PacketFactory.swift`
- 新：`Packages/RagnarokModels/Sources/RagnarokModels/NPCShop.swift`
- 改：`Packages/RagnarokGame/Sources/RagnarokGame/Engine/GameSession.swift`、`Core/Models/MessageCenter.swift`、`UI/MapSceneView.swift`
- 新：`Packages/RagnarokGame/Sources/RagnarokGame/UI/NPCShopView.swift`、`UI/NPCShopDealTypeView.swift`

## 验证

1. `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path Packages/RagnarokPackets`（`xcode-select` 指向 CommandLineTools，没有 XCTest；`PacketRegistryTests` 覆盖新注册的 0xcb）；`swift build --package-path Packages/RagnarokGame` 确认三个包编译通过（macOS 目标）。
2. Xcode 预览：`NPCShopView` 买/卖两个 Preview、`NPCShopDealTypeView` Preview 能渲染。
3. 端到端（本地 swift-rathena 起服，走 `/run`）：进 prontera 点一个工具商 NPC → 出现 Deal Type 弹窗 → Buy → 商品列表带图标和价格 → 加 3 个红药到购物车，合计正确 → Buy → 窗口关闭，聊天框出现 msg 54，背包里多了红药，zeny 减少。再点 NPC → Sell → 列表只显示背包里有的东西 → 卖 1 个 → 关闭 + msg 54 + 背包数量减少 + zeny 增加。
4. 边界：zeny 不足时加购被拒并出 msg 55；商店窗口点 Cancel 后再点 NPC 能重新打开（说明 `CZ_NPC_TRADE_QUIT` 生效、服务器 `npc_shopid` 已清）；Deal Type 弹窗 Cancel 不发包、不留残留状态。
