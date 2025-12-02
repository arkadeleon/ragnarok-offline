//
//  PacketRegistry.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/3/24.
//

let registeredPackets: [Int16 : any DecodablePacket.Type] = [

    // MARK: - Common

    // | 0x81 | `logclif_sent_auth_result`, `chclif_send_auth_result`, `clif_authfail_fd` |
    HEADER_SC_NOTIFY_BAN: PACKET_SC_NOTIFY_BAN.self,

    // MARK: - Login

    // | 0x69, 0xac4 | `logclif_auth_ok` |
    HEADER_AC_ACCEPT_LOGIN: PACKET_AC_ACCEPT_LOGIN.self,

    // | 0x6a, 0x83e | `logclif_auth_failed` |
    HEADER_AC_REFUSE_LOGIN: PACKET_AC_REFUSE_LOGIN.self,

    // | 0x1dc | `logclif_reqkey_result` |
    HEADER_AC_ACK_HASH: PACKET_AC_ACK_HASH.self,

    // MARK: - Char

    // | 0x6b | `chclif_mmo_send006b` |
    HEADER_HC_ACCEPT_ENTER: PACKET_HC_ACCEPT_ENTER.self,

    // | 0x6c | `chclif_reject` |
    HEADER_HC_REFUSE_ENTER: PACKET_HC_REFUSE_ENTER.self,

    // | 0x6d, 0xb6f | `chclif_createnewchar` |
    HEADER_HC_ACCEPT_MAKECHAR: PACKET_HC_ACCEPT_MAKECHAR.self,

    // | 0x6e | `chclif_createnewchar_refuse` |
    HEADER_HC_REFUSE_MAKECHAR: PACKET_HC_REFUSE_MAKECHAR.self,

    // | 0x6f | `chclif_delchar` |
    HEADER_HC_ACCEPT_DELETECHAR: PACKET_HC_ACCEPT_DELETECHAR.self,

    // | 0x70 | `chclif_refuse_delchar` |
    HEADER_HC_REFUSE_DELETECHAR: PACKET_HC_REFUSE_DELETECHAR.self,

    // | 0x71, 0xac5 | `chclif_send_map_data` |
    HEADER_HC_NOTIFY_ZONESVR: PACKET_HC_NOTIFY_ZONESVR.self,

    // | 0x20d | `chclif_block_character` |
    HEADER_HC_BLOCK_CHARACTER: PACKET_HC_BLOCK_CHARACTER.self,

    // | 0x828 | `chclif_char_delete2_ack` |
    HEADER_HC_DELETE_CHAR3_RESERVED: PACKET_HC_DELETE_CHAR3_RESERVED.self,

    // | 0x82a | `chclif_char_delete2_accept_ack` |
    HEADER_HC_DELETE_CHAR3: PACKET_HC_DELETE_CHAR3.self,

    // | 0x82c | `chclif_char_delete2_cancel_ack` |
    HEADER_HC_DELETE_CHAR3_CANCEL: PACKET_HC_DELETE_CHAR3_CANCEL.self,

    // | 0x82d | `chclif_mmo_send082d` |
    HEADER_HC_ACCEPT_ENTER2: PACKET_HC_ACCEPT_ENTER2.self,

    // | 0x840 | `chclif_accessible_maps` |
    HEADER_HC_NOTIFY_ACCESSIBLE_MAPNAME: PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self,

    // | 0x8b9 | `chclif_pincode_sendstate` |
    HEADER_HC_SECOND_PASSWD_LOGIN: PACKET_HC_SECOND_PASSWD_LOGIN.self,

    // | 0x99d, 0xb72 | `chclif_mmo_send099d` |
    HEADER_HC_ACK_CHARINFO_PER_PAGE: PACKET_HC_ACK_CHARINFO_PER_PAGE.self,

    // | 0x9a0 | `chclif_charlist_notify` |
    HEADER_HC_CHARLIST_NOTIFY: PACKET_HC_CHARLIST_NOTIFY.self,

    // MARK: - Map

    // | 0x73, 0x2eb, 0xa18 | `clif_authok` |
    HEADER_ZC_ACCEPT_ENTER: PACKET_ZC_ACCEPT_ENTER.self,

    // | 0x74 | `clif_authrefuse` |
    HEADER_ZC_REFUSE_ENTER: PACKET_ZC_REFUSE_ENTER.self,

    // | 0x78, 0x1d8, 0x22a, 0x2ee, 0x7f9, 0x857, 0x915, 0x9dd, 0x9ff | `clif_set_unit_idle`, `clif_sendfakenpc` |
    packet_header_idle_unitType: packet_idle_unit.self,

    // | 0x79, 0x1d9, 0x22b, 0x2ed, 0x7f8, 0x858, 0x90f, 0x9dc, 0x9fe | `clif_spawn_unit` |
    packet_header_spawn_unitType: packet_spawn_unit.self,

    // | 0x7b, 0x1da, 0x22c, 0x2ec, 0x7f7, 0x856, 0x914, 0x9db, 0x9fd | `clif_set_unit_walking` |
    packet_header_unit_walkingType: packet_unit_walking.self,

    // | 0x7f | `clif_notify_time` |
    HEADER_ZC_NOTIFY_TIME: PACKET_ZC_NOTIFY_TIME.self,

    // | 0x80 | `clif_clearunit_single`, `clif_clearunit_area` |
    HEADER_ZC_NOTIFY_VANISH: PACKET_ZC_NOTIFY_VANISH.self,

    // | 0x87 | `clif_walkok` |
    HEADER_ZC_NOTIFY_PLAYERMOVE: PACKET_ZC_NOTIFY_PLAYERMOVE.self,

    // | 0x88 | `clif_fixpos` |
    HEADER_ZC_STOPMOVE: PACKET_ZC_STOPMOVE.self,

    // | 0x8a, 0x2e1, 0x8c8 | `clif_damage`, `clif_takeitem`, `clif_sitting`, `clif_standing` |
    HEADER_ZC_NOTIFY_ACT: PACKET_ZC_NOTIFY_ACT.self,

    // | 0x8d | `clif_GlobalMessage`, `clif_disp_overhead_` |
    HEADER_ZC_NOTIFY_CHAT: PACKET_ZC_NOTIFY_CHAT.self,

    // | 0x8e | `clif_displaymessage` |
    HEADER_ZC_NOTIFY_PLAYERCHAT: PACKET_ZC_NOTIFY_PLAYERCHAT.self,

    // | 0x91 | `clif_changemap` |
    HEADER_ZC_NPCACK_MAPMOVE: PACKET_ZC_NPCACK_MAPMOVE.self,

    // | 0x92, 0xac7 | `clif_changemapserver` |
    HEADER_ZC_NPCACK_SERVERMOVE: PACKET_ZC_NPCACK_SERVERMOVE.self,

    // | 0x95, 0xadf | `clif_name` |
    HEADER_ZC_ACK_REQNAMEALL_NPC: PACKET_ZC_ACK_REQNAMEALL_NPC.self,

    // | 0x97, 0x9de | `clif_wis_message` |
    HEADER_ZC_WHISPER: PACKET_ZC_WHISPER.self,

    // | 0x98, 0x9df | `clif_wis_end` |
    HEADER_ZC_ACK_WHISPER: PACKET_ZC_ACK_WHISPER.self,

    // | 0x9a | `clif_broadcast` |
    HEADER_ZC_BROADCAST: PACKET_ZC_BROADCAST.self,

    // | 0x9c | `clif_changed_dir` |
    HEADER_ZC_CHANGE_DIRECTION: PACKET_ZC_CHANGE_DIRECTION.self,

    // | 0x9d | `clif_getareachar_item` |
    HEADER_ZC_ITEM_ENTRY: PACKET_ZC_ITEM_ENTRY.self,

    // | 0x9e, 0x84b, 0xadd | `clif_dropflooritem` |
    packet_header_dropflooritemType: packet_dropflooritem.self,

    // | 0xa0, 0x29a, 0x2d4, 0x990, 0xa0c, 0xa37, 0xb41 | `clif_additem` |
    HEADER_ZC_ITEM_PICKUP_ACK: PACKET_ZC_ITEM_PICKUP_ACK.self,

    // | 0xa1 | `clif_clearflooritem` |
    HEADER_ZC_ITEM_DISAPPEAR: PACKET_ZC_ITEM_DISAPPEAR.self,

    // | 0xa3, 0x1ee, 0x2e8, 0x991, 0xb09 | `clif_inventorylist` |
    packet_header_inventorylistnormalType: packet_itemlist_normal.self,

    // | 0xa4, 0x295, 0x2d0, 0x992, 0xa0d, 0xb0a, 0xb39 | `clif_inventorylist` |
    packet_header_inventorylistequipType: packet_itemlist_equip.self,

    // | 0xa5, 0x295, 0x2ea, 0x995, 0xb09 | `clif_storagelist` (duplicated) |
//  packet_header_storageListNormalType: ZC_STORE_ITEMLIST_NORMAL.self,

    // | 0xa6, 0x296, 0x2d1, 0x996, 0xa10, 0xb0a, 0xb39 | `clif_storagelist` (duplicated) |
//  packet_header_storageListEquipType: ZC_STORE_ITEMLIST_EQUIP.self,

    // | 0xa8, 0x1c8 | `clif_useitemack` |
    packet_header_useItemAckType: PACKET_ZC_USE_ITEM_ACK.self,

    // | 0xaa, 0x8d0, 0x999 | `clif_equipitemack` |
    HEADER_ZC_REQ_WEAR_EQUIP_ACK: PACKET_ZC_REQ_WEAR_EQUIP_ACK.self,

    // | 0xac, 0x8d1, 0x99a | `clif_unequipitemack` |
    HEADER_ZC_REQ_TAKEOFF_EQUIP_ACK: PACKET_ZC_REQ_TAKEOFF_EQUIP_ACK.self,

    // | 0xaf | `clif_dropitem` |
    HEADER_ZC_ITEM_THROW_ACK: PACKET_ZC_ITEM_THROW_ACK.self,

    // | 0xb0 | `clif_par_change` |
    HEADER_ZC_PAR_CHANGE: PACKET_ZC_PAR_CHANGE.self,

    // | 0xb1 | `clif_longpar_change` |
    HEADER_ZC_LONGPAR_CHANGE: PACKET_ZC_LONGPAR_CHANGE.self,

    // | 0xb3 | `clif_charselectok` |
    HEADER_ZC_RESTART_ACK: PACKET_ZC_RESTART_ACK.self,

    // | 0xb4 | `clif_scriptmes` |
    HEADER_ZC_SAY_DIALOG: PACKET_ZC_SAY_DIALOG.self,

    // | 0xb5 | `clif_scriptnext` |
    HEADER_ZC_WAIT_DIALOG: PACKET_ZC_WAIT_DIALOG.self,

    // | 0xb6 | `clif_scriptclose` |
    HEADER_ZC_CLOSE_DIALOG: PACKET_ZC_CLOSE_DIALOG.self,

    // | 0xb7 | `clif_scriptmenu` |
    HEADER_ZC_MENU_LIST: PACKET_ZC_MENU_LIST.self,

    // | 0xbc | `clif_statusupack` |
    HEADER_ZC_STATUS_CHANGE_ACK: PACKET_ZC_STATUS_CHANGE_ACK.self,

    // | 0xbd | `clif_initialstatus` |
    HEADER_ZC_STATUS: PACKET_ZC_STATUS.self,

    // | 0xbe | `clif_zc_status_change` |
    HEADER_ZC_STATUS_CHANGE: PACKET_ZC_STATUS_CHANGE.self,

    // | 0xc0 | `clif_emotion` |
    HEADER_ZC_EMOTION: PACKET_ZC_EMOTION.self,

    // | 0xc2 | `clif_user_count` |
    HEADER_ZC_USER_COUNT: PACKET_ZC_USER_COUNT.self,

    // | 0xc3, 0x1d7 | `clif_sprite_change` |
    packet_header_sendLookType: PACKET_ZC_SPRITE_CHANGE.self,

    // | 0xc4 | `clif_npcbuysell` |
    HEADER_ZC_SELECT_DEALTYPE: PACKET_ZC_SELECT_DEALTYPE.self,

    // | 0xc6, 0xb77 | `clif_buylist` |
    HEADER_ZC_PC_PURCHASE_ITEMLIST: PACKET_ZC_PC_PURCHASE_ITEMLIST.self,

    // | 0xc7 | `clif_selllist` |
    HEADER_ZC_PC_SELL_ITEMLIST: PACKET_ZC_PC_SELL_ITEMLIST.self,

    // | 0xca | `clif_npc_buy_result` |
    HEADER_ZC_PC_PURCHASE_RESULT: PACKET_ZC_PC_PURCHASE_RESULT.self,

    // | 0xcb | `clif_npc_sell_result` |
//  HEADER_ZC_PC_SELL_RESULT: PACKET_ZC_PC_SELL_RESULT.self,

    // | 0xcd | `clif_GM_kickack` |
//  HEADER_ZC_ACK_DISCONNECT_CHARACTER: PACKET_ZC_ACK_DISCONNECT_CHARACTER.self,

    // | 0xd1 | `clif_wisexin` |
    HEADER_ZC_SETTING_WHISPER_PC: PACKET_ZC_SETTING_WHISPER_PC.self,

    // | 0xd2 | `clif_wisall` |
    HEADER_ZC_SETTING_WHISPER_STATE: PACKET_ZC_SETTING_WHISPER_STATE.self,

    // | 0xd4 | `clif_PMIgnoreList` |
    HEADER_ZC_WHISPER_LIST: PACKET_ZC_WHISPER_LIST.self,

    // | 0xd6 | `clif_createchat` |
    HEADER_ZC_ACK_CREATE_CHATROOM: PACKET_ZC_ACK_CREATE_CHATROOM.self,

    // | 0xd7 | `clif_dispchat` |
    HEADER_ZC_ROOM_NEWENTRY: PACKET_ZC_ROOM_NEWENTRY.self,

    // | 0xd8 | `clif_clearchat` |
    HEADER_ZC_DESTROY_ROOM: PACKET_ZC_DESTROY_ROOM.self,

    // | 0xda | `clif_joinchatfail` |
    HEADER_ZC_REFUSE_ENTER_ROOM: PACKET_ZC_REFUSE_ENTER_ROOM.self,

    // | 0xdb | `clif_joinchatok` |
    HEADER_ZC_ENTER_ROOM: PACKET_ZC_ENTER_ROOM.self,

    // | 0xdc | `clif_addchat` |
    HEADER_ZC_MEMBER_NEWENTRY: PACKET_ZC_MEMBER_NEWENTRY.self,

    // | 0xdd | `clif_chat_leave` |
    HEADER_ZC_MEMBER_EXIT: PACKET_ZC_MEMBER_EXIT.self,

    // | 0xdf | `clif_changechatstatus` |
    HEADER_ZC_CHANGE_CHATROOM: PACKET_ZC_CHANGE_CHATROOM.self,

    // | 0xe1 | `clif_chat_role` |
    HEADER_ZC_ROLE_CHANGE: PACKET_ZC_ROLE_CHANGE.self,

    // | 0xe5, 0x1f4 | `clif_traderequest` |
    HEADER_ZC_REQ_EXCHANGE_ITEM: PACKET_ZC_REQ_EXCHANGE_ITEM.self,

    // | 0xe7, 0x1f5 | `clif_traderesponse` |
    HEADER_ZC_ACK_EXCHANGE_ITEM: PACKET_ZC_ACK_EXCHANGE_ITEM.self,

    // | 0xe9, 0x80f, 0xa09, 0xa96, 0xb42 | `clif_tradeadditem` |
    HEADER_ZC_ADD_EXCHANGE_ITEM: PACKET_ZC_ADD_EXCHANGE_ITEM.self,

    // | 0xea | `clif_tradeitemok` |
    HEADER_ZC_ACK_ADD_EXCHANGE_ITEM: PACKET_ZC_ACK_ADD_EXCHANGE_ITEM.self,

    // | 0xec | `clif_tradedeal_lock` |
    HEADER_ZC_CONCLUDE_EXCHANGE_ITEM: PACKET_ZC_CONCLUDE_EXCHANGE_ITEM.self,

    // | 0xee | `clif_tradecancelled` |
    HEADER_ZC_CANCEL_EXCHANGE_ITEM: PACKET_ZC_CANCEL_EXCHANGE_ITEM.self,

    // | 0xf0 | `clif_tradecompleted` |
    HEADER_ZC_EXEC_EXCHANGE_ITEM: PACKET_ZC_EXEC_EXCHANGE_ITEM.self,

    // | 0xf1 | `clif_tradeundo` |
    HEADER_ZC_EXCHANGEITEM_UNDO: PACKET_ZC_EXCHANGEITEM_UNDO.self,

    // | 0xf2 | `clif_updatestorageamount` |
    HEADER_ZC_NOTIFY_STOREITEM_COUNTINFO: PACKET_ZC_NOTIFY_STOREITEM_COUNTINFO.self,

    // | 0xf4, 0x1c4, 0xa0a, 0xb44 | `clif_storageitemadded` |
    HEADER_ZC_ADD_ITEM_TO_STORE: PACKET_ZC_ADD_ITEM_TO_STORE.self,

    // | 0xf6 | `clif_storageitemremoved` |
    HEADER_ZC_DELETE_ITEM_FROM_STORE: PACKET_ZC_DELETE_ITEM_FROM_STORE.self,

    // | 0xf8 | `clif_storageclose` |
    HEADER_ZC_CLOSE_STORE: PACKET_ZC_CLOSE_STORE.self,

    // | 0xfa | `clif_party_created` |
    HEADER_ZC_ACK_MAKE_GROUP: PACKET_ZC_ACK_MAKE_GROUP.self,

    // | 0xfb, 0xa44, 0xae5 | `clif_party_info` |
    packet_header_partyinfo: PACKET_ZC_GROUP_LIST.self,

    // | 0xfd, 0x2c5 | `clif_party_invite_reply` |
    HEADER_ZC_PARTY_JOIN_REQ_ACK: PACKET_ZC_PARTY_JOIN_REQ_ACK.self,

    // | 0xfe, 0x2c6 | `clif_party_invite` |
    HEADER_ZC_PARTY_JOIN_REQ: PACKET_ZC_PARTY_JOIN_REQ.self,

    // | 0x101, 0x7d8 | `clif_party_option` |
//  HEADER_ZC_REQ_GROUPINFO_CHANGE_V2: PACKET_ZC_REQ_GROUPINFO_CHANGE_V2.self,

    // | 0x104, 0x1e9, 0xa43, 0xae4 | `clif_party_member_info` |
    packet_header_partymemberinfo: PACKET_ZC_ADD_MEMBER_TO_GROUP.self,

    // | 0x105 | `clif_party_withdraw` |
    HEADER_ZC_DELETE_MEMBER_FROM_GROUP: PACKET_ZC_DELETE_MEMBER_FROM_GROUP.self,

    // | 0x106, 0x80e, 0xbab | `clif_hpmeter_single`, `clif_party_hp` |
    HEADER_ZC_NOTIFY_HP_TO_GROUPM: PACKET_ZC_NOTIFY_HP_TO_GROUPM.self,

    // | 0x107 | `clif_party_xy`, `clif_party_xy_remove`, `clif_party_xy_single` |
    HEADER_ZC_NOTIFY_POSITION_TO_GROUPM: PACKET_ZC_NOTIFY_POSITION_TO_GROUPM.self,

    // | 0x109 | `clif_party_message` |
    HEADER_ZC_NOTIFY_CHAT_PARTY: PACKET_ZC_NOTIFY_CHAT_PARTY.self,

    // | 0x10a | `clif_mvp_item` |
    HEADER_ZC_MVP_GETTING_ITEM: PACKET_ZC_MVP_GETTING_ITEM.self,

    // | 0x10b | `clif_mvp_exp` |
    HEADER_ZC_MVP_GETTING_SPECIAL_EXP: PACKET_ZC_MVP_GETTING_SPECIAL_EXP.self,

    // | 0x10c | `clif_mvp_effect` |
    HEADER_ZC_MVP: PACKET_ZC_MVP.self,

    // | 0x10d | `clif_mvp_noitem` |
    HEADER_ZC_THROW_MVPITEM: PACKET_ZC_THROW_MVPITEM.self,

    // | 0x10e | `clif_skillup` |
    HEADER_ZC_SKILLINFO_UPDATE: PACKET_ZC_SKILLINFO_UPDATE.self,

    // | 0x10f, 0xb32 | `clif_skillinfoblock` |
    HEADER_ZC_SKILLINFO_LIST: PACKET_ZC_SKILLINFO_LIST.self,

    // | 0x110 | `clif_skill_fail` |
    HEADER_ZC_ACK_TOUSESKILL: PACKET_ZC_ACK_TOUSESKILL.self,

    // | 0x111, 0xb31 | `clif_addskill` |
    HEADER_ZC_ADD_SKILL: PACKET_ZC_ADD_SKILL.self,

    // | 0x114, 0x1de | `clif_skill_damage` |
    HEADER_ZC_NOTIFY_SKILL: PACKET_ZC_NOTIFY_SKILL.self,

    // | 0x115 | `clif_skill_damage2` |
    HEADER_ZC_NOTIFY_SKILL_POSITION: PACKET_ZC_NOTIFY_SKILL_POSITION.self,

    // | 0x117 | `clif_skill_poseffect` |
    HEADER_ZC_NOTIFY_GROUNDSKILL: PACKET_ZC_NOTIFY_GROUNDSKILL.self,

    // | 0x119, 0x229 | `clif_changeoption_target` |
    HEADER_ZC_STATE_CHANGE: PACKET_ZC_STATE_CHANGE.self,

    // | 0x11a, 0x9cb | `clif_skill_nodamage` |
    HEADER_ZC_USE_SKILL: PACKET_ZC_USE_SKILL.self,

    // | 0x11c, 0xabe | `clif_skill_warppoint` |
    HEADER_ZC_WARPLIST: PACKET_ZC_WARPLIST.self,

    // | 0x11e | `clif_skill_memomessage` |
    HEADER_ZC_ACK_REMEMBER_WARPPOINT: PACKET_ZC_ACK_REMEMBER_WARPPOINT.self,

    // | 0x11f, 0x8c7, 0x99f, 0x9ca | `clif_getareachar_skillunit` |
    packet_header_skill_entryType: packet_skill_entry.self,

    // | 0x120 | `clif_clearchar_skillunit`, `clif_skill_delunit` |
    HEADER_ZC_SKILL_DISAPPEAR: PACKET_ZC_SKILL_DISAPPEAR.self,

    // | 0x121 | `clif_cartcount` |
    HEADER_ZC_NOTIFY_CARTITEM_COUNTINFO: PACKET_ZC_NOTIFY_CARTITEM_COUNTINFO.self,

    // | 0x122, 0x297, 0x2d2, 0x994, 0xa0f, 0xb0a, 0xb39 | (duplicated) |
//  packet_header_cartlistequipType: packet_itemlist_equip.self,

    // | 0x123, 0x1ef, 0x2e9, 0x993, 0xb09 | (duplicated) |
//  packet_header_cartlistnormalType: packet_itemlist_normal.self,

    // | 0x124, 0x1c5, 0xa0b, 0xb45 | `clif_cart_additem` |
    HEADER_ZC_ADD_ITEM_TO_CART: PACKET_ZC_ADD_ITEM_TO_CART.self,

    // | 0x125 | `clif_cart_delitem` |
    HEADER_ZC_DELETE_ITEM_FROM_CART: PACKET_ZC_DELETE_ITEM_FROM_CART.self,

    // | 0x12b | `clif_clearcart` |
    HEADER_ZC_CARTOFF: PACKET_ZC_CARTOFF.self,

    // | 0x12c | `clif_cart_additem_ack` |
    HEADER_ZC_ACK_ADDITEM_TO_CART: PACKET_ZC_ACK_ADDITEM_TO_CART.self,

    // | 0x12d | `clif_openvendingreq` |
    HEADER_ZC_OPENSTORE: PACKET_ZC_OPENSTORE.self,

    // | 0x131 | `clif_showvendingboard` |
    HEADER_ZC_STORE_ENTRY: PACKET_ZC_STORE_ENTRY.self,

    // | 0x132 | `clif_closevendingboard` |
    HEADER_ZC_DISAPPEAR_ENTRY: PACKET_ZC_DISAPPEAR_ENTRY.self,

    // | 0x133, 0x800, 0xb3d | `clif_vendinglist` |
    HEADER_ZC_PC_PURCHASE_ITEMLIST_FROMMC: PACKET_ZC_PC_PURCHASE_ITEMLIST_FROMMC.self,

    // | 0x135 | `clif_buyvending` |
    HEADER_ZC_PC_PURCHASE_RESULT_FROMMC: PACKET_ZC_PC_PURCHASE_RESULT_FROMMC.self,

    // | 0x136, 0xb40 | `clif_openvending` |
    HEADER_ZC_PC_PURCHASE_MYITEMLIST: PACKET_ZC_PC_PURCHASE_MYITEMLIST.self,

    // | 0x137, 0x9e5 | `clif_vendingreport` |
    HEADER_ZC_DELETEITEM_FROM_MCSTORE: PACKET_ZC_DELETEITEM_FROM_MCSTORE.self,

    // | 0x139 | `clif_movetoattack` |
    HEADER_ZC_ATTACK_FAILURE_FOR_DISTANCE: PACKET_ZC_ATTACK_FAILURE_FOR_DISTANCE.self,

    // | 0x13a | `clif_attackrange` |
    HEADER_ZC_ATTACK_RANGE: PACKET_ZC_ATTACK_RANGE.self,

    // | 0x13b | `clif_arrow_fail` |
    HEADER_ZC_ACTION_FAILURE: PACKET_ZC_ACTION_FAILURE.self,

    // | 0x13c | `clif_arrowequip` |
    HEADER_ZC_EQUIP_ARROW: PACKET_ZC_EQUIP_ARROW.self,

    // | 0x13d, 0xa27 | `clif_heal` |
    HEADER_ZC_RECOVERY: PACKET_ZC_RECOVERY.self,

    // | 0x13e, 0x7fb, 0xb1a | `clif_skillcasting` |
    HEADER_ZC_USESKILL_ACK: PACKET_ZC_USESKILL_ACK.self,

    // | 0x141 | `clif_couplestatus` |
    HEADER_ZC_COUPLESTATUS: PACKET_ZC_COUPLESTATUS.self,

    // | 0x142 | `clif_scriptinput` |
    HEADER_ZC_OPEN_EDITDLG: PACKET_ZC_OPEN_EDITDLG.self,

    // | 0x144 | `clif_viewpoint` |
    HEADER_ZC_COMPASS: PACKET_ZC_COMPASS.self,

    // | 0x145, 0x1b3 | `clif_cutin` |
    HEADER_ZC_SHOW_IMAGE: PACKET_ZC_SHOW_IMAGE.self,

    // | 0x147 | `clif_item_skill` |
    HEADER_ZC_AUTORUN_SKILL: PACKET_ZC_AUTORUN_SKILL.self,

    // | 0x148 | `clif_resurrection` |
    HEADER_ZC_RESURRECTION: PACKET_ZC_RESURRECTION.self,

    // | 0x14a | `clif_manner_message` |
//  HEADER_ZC_ACK_GIVE_MANNER_POINT: PACKET_ZC_ACK_GIVE_MANNER_POINT.self,

    // | 0x14b | `clif_GM_silence` |
    HEADER_ZC_NOTIFY_MANNER_POINT_GIVEN: PACKET_ZC_NOTIFY_MANNER_POINT_GIVEN.self,

    // | 0x14c | `clif_guild_allianceinfo` |
    HEADER_ZC_MYGUILD_BASIC_INFO: PACKET_ZC_MYGUILD_BASIC_INFO.self,

    // | 0x14e | `clif_guild_masterormember` |
    HEADER_ZC_ACK_GUILD_MENUINTERFACE: PACKET_ZC_ACK_GUILD_MENUINTERFACE.self,

    // | 0x150, 0x1b6, 0xa84, 0xb7b | `clif_guild_basicinfo` |
    HEADER_ZC_GUILD_INFO: PACKET_ZC_GUILD_INFO.self,

    // | 0x152, 0xb36 | `clif_guild_emblem` |
    HEADER_ZC_GUILD_EMBLEM_IMG: PACKET_ZC_GUILD_EMBLEM_IMG.self,

    // | 0x154, 0xaa5, 0xb7d | `clif_guild_memberlist` |
    HEADER_ZC_MEMBERMGR_INFO: PACKET_ZC_MEMBERMGR_INFO.self,

    // | 0x156 | `clif_guild_memberpositionchanged` |
//  HEADER_ZC_ACK_REQ_CHANGE_MEMBERS: PACKET_ZC_ACK_REQ_CHANGE_MEMBERS.self,

    // | 0x15a, 0xa83 | `clif_guild_leave` |
    packet_header_guildLeave: PACKET_ZC_ACK_LEAVE_GUILD2.self,

    // | 0x15c, 0x839, 0xa82 | `clif_guild_expulsion` |
    packet_header_guildExpulsion: PACKET_ZC_ACK_BAN_GUILD3.self,

    // | 0x15e | `clif_guild_broken` |
    HEADER_ZC_ACK_DISORGANIZE_GUILD_RESULT: PACKET_ZC_ACK_DISORGANIZE_GUILD_RESULT.self,

    // | 0x160 | `clif_guild_positioninfolist` |
    HEADER_ZC_POSITION_INFO: PACKET_ZC_POSITION_INFO.self,

    // | 0x162 | `clif_guild_skillinfo` |
    HEADER_ZC_GUILD_SKILLINFO: PACKET_ZC_GUILD_SKILLINFO.self,

    // | 0x163, 0xa87, 0x0b7c | `clif_guild_expulsionlist` |
    HEADER_ZC_BAN_LIST: PACKET_ZC_BAN_LIST.self,

    // | 0x166 | `clif_guild_positionnamelist` |
    HEADER_ZC_POSITION_ID_NAME_INFO: PACKET_ZC_POSITION_ID_NAME_INFO.self,

    // | 0x167 | `clif_guild_created` |
    HEADER_ZC_RESULT_MAKE_GUILD: PACKET_ZC_RESULT_MAKE_GUILD.self,

    // | 0x169 | `clif_guild_inviteack` |
    HEADER_ZC_ACK_REQ_JOIN_GUILD: PACKET_ZC_ACK_REQ_JOIN_GUILD.self,

    // | 0x16a | `clif_guild_invite` |
    HEADER_ZC_REQ_JOIN_GUILD: PACKET_ZC_REQ_JOIN_GUILD.self,

    // | 0x16c | `clif_guild_belonginfo` |
    HEADER_ZC_UPDATE_GDID: PACKET_ZC_UPDATE_GDID.self,

    // | 0x16d, 0x1f2 | `clif_guild_memberlogin_notice` |
//  HEADER_ZC_UPDATE_CHARSTAT: PACKET_ZC_UPDATE_CHARSTAT.self,

    // | 0x16f | `clif_guild_notice` |
    HEADER_ZC_GUILD_NOTICE: PACKET_ZC_GUILD_NOTICE.self,

    // | 0x171 | `clif_guild_reqalliance` |
    HEADER_ZC_REQ_ALLY_GUILD: PACKET_ZC_REQ_ALLY_GUILD.self,

    // | 0x173 | `clif_guild_allianceack` |
    HEADER_ZC_ACK_REQ_ALLY_GUILD: PACKET_ZC_ACK_REQ_ALLY_GUILD.self,

    // | 0x174 | `clif_guild_positionchanged` |
//  HEADER_ZC_ACK_CHANGE_GUILD_POSITIONINFO: PACKET_ZC_ACK_CHANGE_GUILD_POSITIONINFO.self,

    // | 0x177 | `clif_item_identify_list` |
//  HEADER_ZC_ITEMIDENTIFY_LIST: PACKET_ZC_ITEMIDENTIFY_LIST.self,

    // | 0x179 | `clif_item_identified` |
    HEADER_ZC_ACK_ITEMIDENTIFY: PACKET_ZC_ACK_ITEMIDENTIFY.self,

    // | 0x17b | `clif_use_card` |
//  HEADER_ZC_ITEMCOMPOSITION_LIST: PACKET_ZC_ITEMCOMPOSITION_LIST.self,

    // | 0x17d | `clif_insert_card` |
    HEADER_ZC_ACK_ITEMCOMPOSITION: PACKET_ZC_ACK_ITEMCOMPOSITION.self,

    // | 0x17f | `clif_guild_message` |
    HEADER_ZC_GUILD_CHAT: PACKET_ZC_GUILD_CHAT.self,

    // | 0x181 | `clif_guild_oppositionack` |
    HEADER_ZC_ACK_REQ_HOSTILE_GUILD: PACKET_ZC_ACK_REQ_HOSTILE_GUILD.self,

    // | 0x184 | `clif_guild_delalliance` |
    HEADER_ZC_DELETE_RELATED_GUILD: PACKET_ZC_DELETE_RELATED_GUILD.self,

    // | 0x185 | `clif_guild_allianceadded` |
//  HEADER_ZC_ADD_RELATED_GUILD: PACKET_ZC_ADD_RELATED_GUILD.self,

    // | 0x188 | `clif_refine` |
    HEADER_ZC_ACK_ITEMREFINING: PACKET_ZC_ACK_ITEMREFINING.self,

    // | 0x189 | `clif_skill_teleportmessage` |
    HEADER_ZC_NOTIFY_MAPINFO: PACKET_ZC_NOTIFY_MAPINFO.self,

    // | 0x18b | `clif_disconnect_ack` |
    HEADER_ZC_ACK_REQ_DISCONNECT: PACKET_ZC_ACK_REQ_DISCONNECT.self,

    // | 0x18c | `clif_skill_estimation` |
    HEADER_ZC_MONSTER_INFO: PACKET_ZC_MONSTER_INFO.self,

    // | 0x18d | `clif_skill_produce_mix_list` |
    HEADER_ZC_MAKABLEITEMLIST: PACKET_ZC_MAKABLEITEMLIST.self,

    // | 0x18f | `clif_produceeffect` |
    HEADER_ZC_ACK_REQMAKINGITEM: PACKET_ZC_ACK_REQMAKINGITEM.self,

    // | 0x191 | `clif_talkiebox` |
    HEADER_ZC_TALKBOX_CHATCONTENTS: PACKET_ZC_TALKBOX_CHATCONTENTS.self,

    // | 0x192 | `clif_changemapcell` |
    HEADER_ZC_UPDATE_MAPINFO: PACKET_ZC_UPDATE_MAPINFO.self,

    // | 0x194, 0xaf7 | `clif_solved_charname` |
    HEADER_ZC_ACK_REQNAME_BYGID: PACKET_ZC_ACK_REQNAME_BYGID.self,

    // | 0x195, 0xa30 | `clif_name` |
    HEADER_ZC_ACK_REQNAMEALL: PACKET_ZC_ACK_REQNAMEALL.self,

    // | 0x196, 0x43f, 0x983 | `clif_status_change_sub` |
//  packet_header_status_changeType: PACKET_ZC_MSG_STATE_CHANGE.self,

    // | 0x199, 0x99b | `clif_map_property` |
    packet_header_maptypeproperty2Type: PACKET_ZC_MAPPROPERTY_R2.self,

    // | 0x19a | `clif_pvpset` |
//  HEADER_ZC_NOTIFY_RANKING: PACKET_ZC_NOTIFY_RANKING.self,

    // | 0x19b | `clif_misceffect` |
    HEADER_ZC_NOTIFY_EFFECT: PACKET_ZC_NOTIFY_EFFECT.self,

    // | 0x19e | `clif_catch_process` |
    HEADER_ZC_START_CAPTURE: PACKET_ZC_START_CAPTURE.self,

    // | 0x1a0 | `clif_pet_roulette` |
    HEADER_ZC_TRYCAPTURE_MONSTER: PACKET_ZC_TRYCAPTURE_MONSTER.self,

    // | 0x1a2 | `clif_send_petstatus` |
    HEADER_ZC_PROPERTY_PET: PACKET_ZC_PROPERTY_PET.self,

    // | 0x1a3 | `clif_pet_food` |
    HEADER_ZC_FEED_PET: PACKET_ZC_FEED_PET.self,

    // | 0x1a4 | `clif_send_petdata` |
    HEADER_ZC_CHANGESTATE_PET: PACKET_ZC_CHANGESTATE_PET.self,

    // | 0x1a6 | `clif_sendegg` |
//  HEADER_ZC_PETEGG_LIST: PACKET_ZC_PETEGG_LIST.self,

    // | 0x1aa | `clif_pet_emotion` |
    HEADER_ZC_PET_ACT: PACKET_ZC_PET_ACT.self,

    // | 0x1ab | `clif_changemanner` |
    HEADER_ZC_PAR_CHANGE_USER: PACKET_ZC_PAR_CHANGE_USER.self,

    // | 0x1ac | `clif_skillunit_update` |
    HEADER_ZC_SKILL_UPDATE: PACKET_ZC_SKILL_UPDATE.self,

    // | 0x1ad | `clif_arrow_create_list`, `clif_elementalconverter_list`, `clif_magicdecoy_list`, `clif_poison_list` |
    HEADER_ZC_MAKINGARROW_LIST: PACKET_ZC_MAKINGARROW_LIST.self,

    // | 0x1b0 | `clif_class_change` |
    HEADER_ZC_NPCSPRITE_CHANGE: PACKET_ZC_NPCSPRITE_CHANGE.self,

    // | 0x1b1 | `clif_showdigit` |
//  HEADER_ZC_SHOWDIGIT: PACKET_ZC_SHOWDIGIT.self,

    // | 0x1b4, 0xb1f, 0xb47 | `clif_guild_emblem_area` |
    HEADER_ZC_CHANGE_GUILD: PACKET_ZC_CHANGE_GUILD.self,

    // | 0x1b9 | `clif_skillcastcancel` |
    HEADER_ZC_DISPEL: PACKET_ZC_DISPEL.self,

    // | 0x1c3 | `clif_broadcast2` |
    HEADER_ZC_BROADCAST2: PACKET_ZC_BROADCAST2.self,

    // | 0x1c9 | `clif_graffiti` |
    packet_header_graffiti_entryType: packet_graffiti_entry.self,

    // | 0x1cd, 0xafb | `clif_autospell` |
    HEADER_ZC_AUTOSPELLLIST: PACKET_ZC_AUTOSPELLLIST.self,

    // | 0x1cf | `clif_devotion` |
//  HEADER_ZC_DEVOTIONLIST: PACKET_ZC_DEVOTIONLIST.self,

    // | 0x1d0 | `clif_abyssball`, `clif_servantball`, `clif_soulball`, `clif_spiritball` |
    HEADER_ZC_SPIRITS: PACKET_ZC_SPIRITS.self,

    // | 0x1d1 | `clif_bladestop` |
    HEADER_ZC_BLADESTOP: PACKET_ZC_BLADESTOP.self,

    // | 0x1d2 | `clif_combo_delay` |
    HEADER_ZC_COMBODELAY: PACKET_ZC_COMBODELAY.self,

    // | 0x1d3 | `clif_soundeffect` |
    HEADER_ZC_SOUND: PACKET_ZC_SOUND.self,

    // | 0x1d4 | `clif_scriptinputstr` |
    HEADER_ZC_OPEN_EDITDLGSTR: PACKET_ZC_OPEN_EDITDLGSTR.self,

    // | 0x1d6 | `clif_map_type` |
    HEADER_ZC_NOTIFY_MAPPROPERTY2: PACKET_ZC_NOTIFY_MAPPROPERTY2.self,

    // | 0x1e0 | `clif_account_name` |
//  HEADER_ZC_ACK_ACCOUNTNAME: PACKET_ZC_ACK_ACCOUNTNAME.self,

    // | 0x1e1 | `clif_spiritball` |
    HEADER_ZC_SPIRITS2: PACKET_ZC_SPIRITS2.self,

    // | 0x1e2 | `clif_marriage_proposal` |
//  HEADER_ZC_REQ_COUPLE: PACKET_ZC_REQ_COUPLE.self,

    // | 0x1e4 | `clif_marriage_process` |
//  HEADER_ZC_START_COUPLE: PACKET_ZC_START_COUPLE.self,

    // | 0x1e6 | `clif_callpartner` |
    HEADER_ZC_COUPLENAME: PACKET_ZC_COUPLENAME.self,

    // | 0x1ea | `clif_wedding_effect` |
    HEADER_ZC_CONGRATULATION: PACKET_ZC_CONGRATULATION.self,

    // | 0x1eb | `clif_guild_xy`, `clif_guild_xy_remove`, `clif_guild_xy_single` |
    HEADER_ZC_NOTIFY_POSITION_TO_GUILDM: PACKET_ZC_NOTIFY_POSITION_TO_GUILDM.self,

    // | 0x1f3 | `clif_specialeffect` |
//  HEADER_ZC_NOTIFY_EFFECT2: PACKET_ZC_NOTIFY_EFFECT2.self,

    // | 0x1f6 | `clif_Adopt_request` |
//  HEADER_ZC_REQ_BABY: PACKET_ZC_REQ_BABY.self,

    // | 0x1fc, 0xb65 | `clif_item_repair_list` |
    HEADER_ZC_REPAIRITEMLIST: PACKET_ZC_REPAIRITEMLIST.self,

    // | 0x1fe | `clif_item_repaireffect` |
    HEADER_ZC_ACK_ITEMREPAIR: PACKET_ZC_ACK_ITEMREPAIR.self,

    // | 0x1ff | `clif_slide` |
    HEADER_ZC_HIGHJUMP: PACKET_ZC_HIGHJUMP.self,

    // | 0x201 | `clif_friendslist_send` |
    HEADER_ZC_FRIENDS_LIST: PACKET_ZC_FRIENDS_LIST.self,

    // | 0x205 | `clif_divorced` |
    HEADER_ZC_DIVORCE: PACKET_ZC_DIVORCE.self,

    // | 0x206 | `clif_friendslist_toggle` |
    HEADER_ZC_FRIENDS_STATE: PACKET_ZC_FRIENDS_STATE.self,

    // | 0x207 | `clif_friendslist_req` |
//  HEADER_ZC_REQ_ADD_FRIENDS: PACKET_ZC_REQ_ADD_FRIENDS.self,

    // | 0x209 | `clif_friendslist_reqack` |
//  HEADER_ZC_ADD_FRIENDS_LIST: PACKET_ZC_ADD_FRIENDS_LIST.self,

    // | 0x20a | `clif_parse_FriendsListRemove` |
//  HEADER_ZC_DELETE_FRIENDS: PACKET_ZC_DELETE_FRIENDS.self,

    // | 0x20e | `clif_starskill` |
//  HEADER_ZC_STARSKILL: PACKET_ZC_STARSKILL.self,

    // | 0x210 | `clif_PVPInfo` |
//  HEADER_ZC_ACK_PVPPOINT: PACKET_ZC_ACK_PVPPOINT.self,

    // | 0x214 | `clif_check` |
//  HEADER_ZC_ACK_STATUS_GM: PACKET_ZC_ACK_STATUS_GM.self,

    // | 0x215 | `clif_gospel_info` |
    HEADER_ZC_SKILLMSG: PACKET_ZC_SKILLMSG.self,

    // | 0x216 | `clif_Adopt_reply` |
//  HEADER_ZC_BABYMSG: PACKET_ZC_BABYMSG.self,

    // | 0x219 | `clif_ranklist` |
    HEADER_ZC_BLACKSMITH_RANK: PACKET_ZC_BLACKSMITH_RANK.self,

    // | 0x21a | `clif_ranklist` |
    HEADER_ZC_ALCHEMIST_RANK: PACKET_ZC_ALCHEMIST_RANK.self,

    // | 0x21b | `clif_update_rankingpoint` |
    HEADER_ZC_BLACKSMITH_POINT: PACKET_ZC_BLACKSMITH_POINT.self,

    // | 0x21c | `clif_update_rankingpoint` |
    HEADER_ZC_ALCHEMIST_POINT: PACKET_ZC_ALCHEMIST_POINT.self,

    // | 0x221 | `clif_item_refine_list` |
    HEADER_ZC_NOTIFY_WEAPONITEMLIST: PACKET_ZC_NOTIFY_WEAPONITEMLIST.self,

    // | 0x223 | `clif_upgrademessage` |
    HEADER_ZC_ACK_WEAPONREFINE: PACKET_ZC_ACK_WEAPONREFINE.self,

    // | 0x224 | `clif_update_rankingpoint` |
    HEADER_ZC_TAEKWON_POINT: PACKET_ZC_TAEKWON_POINT.self,

    // | 0x226 | `clif_ranklist` |
    HEADER_ZC_TAEKWON_RANK: PACKET_ZC_TAEKWON_RANK.self,

    // | 0x22e, 0x9f7, 0xb2f, 0xb76, 0xba4 | `clif_hominfo` |
    HEADER_ZC_PROPERTY_HOMUN: PACKET_ZC_PROPERTY_HOMUN.self,

    // | 0x22f | `clif_hom_food` |
    HEADER_ZC_FEED_MER: PACKET_ZC_FEED_MER.self,

    // | 0x230 | `clif_send_homdata` |
    HEADER_ZC_CHANGESTATE_MER: PACKET_ZC_CHANGESTATE_MER.self,

    // | 0x235 | `clif_homskillinfoblock` |
    HEADER_ZC_HOSKILLINFO_LIST: PACKET_ZC_HOSKILLINFO_LIST.self,

    // | 0x236 | `clif_update_rankingpoint` |
    HEADER_ZC_KILLER_POINT: PACKET_ZC_KILLER_POINT.self,

    // | 0x238 | `clif_ranklist` |
    HEADER_ZC_KILLER_RANK: PACKET_ZC_KILLER_RANK.self,

    // | 0x239 | `clif_homskillup` |
    HEADER_ZC_HOSKILLINFO_UPDATE: PACKET_ZC_HOSKILLINFO_UPDATE.self,

    // | 0x23a | `clif_storagepassword` |
//  HEADER_ZC_REQ_STORE_PASSWORD: PACKET_ZC_REQ_STORE_PASSWORD.self,

    // | 0x23c | `clif_storagepassword_result` |
//  HEADER_ZC_RESULT_STORE_PASSWORD: PACKET_ZC_RESULT_STORE_PASSWORD.self,

    // | 0x240, 0x9f0, 0xa7d, 0xac2 | `clif_Mail_refreshinbox` |
//  HEADER_ZC_MAIL_REQ_GET_LIST: PACKET_ZC_MAIL_REQ_GET_LIST.self,

    // | 0x242 | `clif_Mail_read` |
//  HEADER_ZC_MAIL_REQ_OPEN: PACKET_ZC_MAIL_REQ_OPEN.self,

    // | 0x245 | `clif_mail_getattachment` |
//  HEADER_ZC_MAIL_REQ_GET_ITEM: PACKET_ZC_MAIL_REQ_GET_ITEM.self,

    // | 0x249 | `clif_Mail_send` |
//  HEADER_ZC_MAIL_REQ_SEND: PACKET_ZC_MAIL_REQ_SEND.self,

    // | 0x24a | `clif_Mail_new` |
    HEADER_ZC_MAIL_RECEIVE: PACKET_ZC_MAIL_RECEIVE.self,

    // | 0x250 | `clif_Auction_message` |
//  HEADER_ZC_AUCTION_RESULT: PACKET_ZC_AUCTION_RESULT.self,

    // | 0x252 | `clif_Auction_results` |
//  HEADER_ZC_AUCTION_ITEM_REQ_SEARCH: PACKET_ZC_AUCTION_ITEM_REQ_SEARCH.self,

    // | 0x253 | `clif_feel_req` |
//  HEADER_ZC_STARPLACE: PACKET_ZC_STARPLACE.self,

    // | 0x255 | `clif_Mail_setattachment` |
//  HEADER_ZC_ACK_MAIL_ADD_ITEM: PACKET_ZC_ACK_MAIL_ADD_ITEM.self,

    // | 0x256 | `clif_Auction_setitem` |
//  HEADER_ZC_ACK_AUCTION_ADD_ITEM: PACKET_ZC_ACK_AUCTION_ADD_ITEM.self,

    // | 0x257 | `clif_mail_delete` |
//  HEADER_ZC_ACK_MAIL_DELETE: PACKET_ZC_ACK_MAIL_DELETE.self,

    // | 0x25a | `clif_cooking_list` |
    HEADER_ZC_MAKINGITEM_LIST: PACKET_ZC_MAKINGITEM_LIST.self,

    // | 0x25e | `clif_Auction_close` |
//  HEADER_ZC_AUCTION_ACK_MY_SELL_STOP: PACKET_ZC_AUCTION_ACK_MY_SELL_STOP.self,

    // | 0x25f | `clif_Auction_openwindow` |
//  HEADER_ZC_AUCTION_WINDOWS: PACKET_ZC_AUCTION_WINDOWS.self,

    // | 0x260 | `clif_Mail_window` |
//  HEADER_ZC_MAIL_WINDOWS: PACKET_ZC_MAIL_WINDOWS.self,

    // | 0x274 | `clif_Mail_return` |
//  HEADER_ZC_ACK_MAIL_RETURN: PACKET_ZC_ACK_MAIL_RETURN.self,

    // | 0x283 | `clif_parse_WantToConnection` |
    HEADER_ZC_AID: PACKET_ZC_AID.self,

    // | 0x284, 0xb69 | `clif_specialeffect_value` |
    HEADER_ZC_NOTIFY_EFFECT3: PACKET_ZC_NOTIFY_EFFECT3.self,

    // | 0x287 | `clif_cashshop_show` |
    HEADER_ZC_PC_CASH_POINT_ITEMLIST: PACKET_ZC_PC_CASH_POINT_ITEMLIST.self,

    // | 0x289 | `clif_cashshop_ack` |
//  HEADER_ZC_PC_CASH_POINT_UPDATE: PACKET_ZC_PC_CASH_POINT_UPDATE.self,

    // | 0x28a | `clif_changeoption2` |
    HEADER_ZC_NPC_SHOWEFST_UPDATE: PACKET_ZC_NPC_SHOWEFST_UPDATE.self,

    // | 0x291 | `clif_msg` |
    HEADER_ZC_MSG: PACKET_ZC_MSG.self,

    // | 0x293 | `clif_bossmapinfo` |
    HEADER_ZC_BOSS_INFO: PACKET_ZC_BOSS_INFO.self,

    // | 0x294 | `clif_readbook` |
//  HEADER_ZC_READ_BOOK: PACKET_ZC_READ_BOOK.self,

    // | 0x298 | `clif_rental_time` |
    HEADER_ZC_CASH_TIME_COUNTER: PACKET_ZC_CASH_TIME_COUNTER.self,

    // | 0x299 | `clif_rental_expired` |
    HEADER_ZC_CASH_ITEM_DELETE: PACKET_ZC_CASH_ITEM_DELETE.self,

    // | 0x29b | `clif_mercenary_info` |
//  HEADER_ZC_MER_INIT: PACKET_ZC_MER_INIT.self,

    // | 0x29d | `clif_mercenary_skillblock` |
//  HEADER_ZC_MER_SKILLINFO_LIST: PACKET_ZC_MER_SKILLINFO_LIST.self,

    // | 0x2a2 | `clif_mercenary_updatestatus` |
//  HEADER_ZC_MER_PAR_CHANGE: PACKET_ZC_MER_PAR_CHANGE.self,

    // | 0x2b1, 0x97a, 0x9f8, 0xaff | `clif_quest_send_list` |
//  packet_header_questListType: PACKET_ZC_ALL_QUEST_LIST.self,

    // | 0x2b2 | `clif_quest_send_mission` |
//  HEADER_ZC_ALL_QUEST_MISSION: PACKET_ZC_ALL_QUEST_MISSION.self,

    // | 0x2b3, 0x9f9, 0xb0c | `clif_quest_add` |
//  packet_header_questAddType: PACKET_ZC_ADD_QUEST.self,

    // | 0x2b4 | `clif_quest_delete` |
//  HEADER_ZC_DEL_QUEST: PACKET_ZC_DEL_QUEST.self,

    // | 0x2b5, 0x9fa, 0xafe | `clif_quest_update_objective` |
//  packet_header_questUpdateType: PACKET_ZC_UPDATE_MISSION_HUNT.self,

    // | 0x2b7 | `clif_quest_update_status` |
//  HEADER_ZC_ACTIVE_QUEST: PACKET_ZC_ACTIVE_QUEST.self,

    // | 0x2b8, 0xb67 | `clif_party_show_picker` |
    HEADER_ZC_ITEM_PICKUP_PARTY: PACKET_ZC_ITEM_PICKUP_PARTY.self,

    // | 0x2b9, 0x7d9, 0xa00, 0xb20 | `clif_hotkeys_send` |
    HEADER_ZC_SHORTCUT_KEY_LIST: PACKET_ZC_SHORTCUT_KEY_LIST.self,

    // | 0x2bb | `clif_item_damaged` |
    HEADER_ZC_EQUIPITEM_DAMAGED: PACKET_ZC_EQUIPITEM_DAMAGED.self,

    // | 0x2c1 | `clif_displaymessage`, `clif_channel_msg`, `clif_messagecolor_target` |
    HEADER_ZC_NPC_CHAT: PACKET_ZC_NPC_CHAT.self,

    // | 0x2c2 |
    0x2c2: PACKET_ZC_FORMATSTRING_MSG.self,

    // | 0x2c9 | `clif_partyinvitationstate` |
    HEADER_ZC_PARTY_CONFIG: PACKET_ZC_PARTY_CONFIG.self,

    // | 0x2cb | `clif_instance_create` |
//  HEADER_ZC_MEMORIALDUNGEON_SUBSCRIPTION_INFO: PACKET_ZC_MEMORIALDUNGEON_SUBSCRIPTION_INFO.self,

    // | 0x2cc | `clif_instance_changewait` |
//  HEADER_ZC_MEMORIALDUNGEON_SUBSCRIPTION_NOTIFY: PACKET_ZC_MEMORIALDUNGEON_SUBSCRIPTION_NOTIFY.self,

    // | 0x2cd | `clif_instance_status` |
//  HEADER_ZC_MEMORIALDUNGEON_INFO: PACKET_ZC_MEMORIALDUNGEON_INFO.self,

    // | 0x2ce | `clif_instance_changestatus` |
//  HEADER_ZC_MEMORIALDUNGEON_NOTIFY: PACKET_ZC_MEMORIALDUNGEON_NOTIFY.self,

    // | 0x2d3 | `clif_notify_bindOnEquip` |
    HEADER_ZC_NOTIFY_BIND_ON_EQUIP: PACKET_ZC_NOTIFY_BIND_ON_EQUIP.self,

    // | 0x2d7, 0x859, 0x906, 0x997, 0xa2d, 0xb03, 0xb37 | `clif_viewequip_ack` |
    HEADER_ZC_EQUIPWIN_MICROSCOPE: PACKET_ZC_EQUIPWIN_MICROSCOPE.self,

    // | 0x2d9 | `clif_configuration` |
    HEADER_ZC_CONFIG: PACKET_ZC_CONFIG.self,

    // | 0x2da | `clif_equipcheckbox` |
    HEADER_ZC_CONFIG_NOTIFY: PACKET_ZC_CONFIG_NOTIFY.self,

    // | 0x2dc | `clif_bg_message` |
//  HEADER_ZC_BATTLEFIELD_CHAT: PACKET_ZC_BATTLEFIELD_CHAT.self,

    // | 0x2dd | `clif_sendbgemblem_area` |
//  HEADER_ZC_BATTLEFIELD_NOTIFY_CAMPINFO: PACKET_ZC_BATTLEFIELD_NOTIFY_CAMPINFO.self,

    // | 0x2de | `clif_bg_updatescore` |
//  HEADER_ZC_BATTLEFIELD_NOTIFY_POINT: PACKET_ZC_BATTLEFIELD_NOTIFY_POINT.self,

    // | 0x2df | `clif_bg_xy` |
//  HEADER_ZC_BATTLEFIELD_NOTIFY_POSITION: PACKET_ZC_BATTLEFIELD_NOTIFY_POSITION.self,

    // | 0x2e0, 0xa0e, 0xbaa | `clif_bg_hp` |
    HEADER_ZC_BATTLEFIELD_NOTIFY_HP: PACKET_ZC_BATTLEFIELD_NOTIFY_HP.self,

    // | 0x2ef | `clif_font` |
//  HEADER_ZC_NOTIFY_FONT: PACKET_ZC_NOTIFY_FONT.self,

    // | 0x2f0 | `clif_progressbar` |
//  HEADER_ZC_PROGRESS: PACKET_ZC_PROGRESS.self,

    // | 0x2f2 | `clif_progressbar_abort` |
//  HEADER_ZC_PROGRESS_CANCEL: PACKET_ZC_PROGRESS_CANCEL.self,

    // | 0x43d | `clif_skill_cooldown` |
    HEADER_ZC_SKILL_POSTDELAY: PACKET_ZC_SKILL_POSTDELAY.self,

    // | 0x440 | `clif_millenniumshield`, `clif_millenniumshield_single` |
    HEADER_ZC_MILLENNIUMSHIELD: PACKET_ZC_MILLENNIUMSHIELD.self,

    // | 0x441 | `clif_deleteskill` |
    HEADER_ZC_SKILLINFO_DELETE: PACKET_ZC_SKILLINFO_DELETE.self,

    // | 0x442 | `clif_autoshadowspell_list` |
    HEADER_ZC_SKILL_SELECT_REQUEST: PACKET_ZC_SKILL_SELECT_REQUEST.self,

    // | 0x446 | `clif_quest_show_event` |
    HEADER_ZC_QUEST_NOTIFY_EFFECT: PACKET_ZC_QUEST_NOTIFY_EFFECT.self,

    // | 0x7db, 0xba5 | `clif_homunculus_updatestatus` |
    HEADER_ZC_HO_PAR_CHANGE: PACKET_ZC_HO_PAR_CHANGE.self,

    // | 0x7e1, 0xb33 | `clif_skillinfo` |
    HEADER_ZC_SKILLINFO_UPDATE2: PACKET_ZC_SKILLINFO_UPDATE2.self,

    // | 0x7e2 | `clif_msg_value` |
    HEADER_ZC_MSG_VALUE: PACKET_ZC_MSG_VALUE.self,

    // | 0x7e3 | `clif_skill_itemlistwindow` |
//  HEADER_ZC_ITEMLISTWIN_OPEN: PACKET_ZC_ITEMLISTWIN_OPEN.self,

    // | 0x7e6 | `clif_msg_skill` |
    HEADER_ZC_MSG_SKILL: PACKET_ZC_MSG_SKILL.self,

    // | 0x7f6, 0xacc | `clif_displayexp` |
//  HEADER_ZC_NOTIFY_EXP: PACKET_ZC_NOTIFY_EXP.self,

    // | 0x7fa | `clif_delitem` |
    HEADER_ZC_DELETE_ITEM_FROM_BODY: PACKET_ZC_DELETE_ITEM_FROM_BODY.self,

    // | 0x7fc | `clif_party_leaderchanged` |
//  HEADER_ZC_CHANGE_GROUP_MASTER: PACKET_ZC_CHANGE_GROUP_MASTER.self,

    // | 0x7fd, 0xbba | `clif_broadcast_obtain_special_item` |
    HEADER_ZC_BROADCASTING_SPECIAL_ITEM_OBTAIN_item: PACKET_ZC_BROADCASTING_SPECIAL_ITEM_OBTAIN_item.self,

    // | 0x7fe | `clif_playBGM` |
    HEADER_ZC_PLAY_NPC_BGM: PACKET_ZC_PLAY_NPC_BGM.self,

    // | 0x803 | `clif_PartyBookingRegisterAck` |
//  HEADER_ZC_PARTY_BOOKING_ACK_REGISTER: PACKET_ZC_PARTY_BOOKING_ACK_REGISTER.self,

    // | 0x805 | `clif_PartyBookingSearchAck` |
//  HEADER_ZC_PARTY_BOOKING_ACK_SEARCH: PACKET_ZC_PARTY_BOOKING_ACK_SEARCH.self,

    // | 0x807 | `clif_PartyBookingDeleteAck` |
//  HEADER_ZC_PARTY_BOOKING_ACK_DELETE: PACKET_ZC_PARTY_BOOKING_ACK_DELETE.self,

    // | 0x809 | `clif_PartyBookingInsertNotify` |
//  HEADER_ZC_PARTY_BOOKING_NOTIFY_INSERT: PACKET_ZC_PARTY_BOOKING_NOTIFY_INSERT.self,

    // | 0x80a | `clif_PartyBookingUpdateNotify` |
//  HEADER_ZC_PARTY_BOOKING_NOTIFY_UPDATE: PACKET_ZC_PARTY_BOOKING_NOTIFY_UPDATE.self,

    // | 0x80b | `clif_PartyBookingDeleteNotify` |
//  HEADER_ZC_PARTY_BOOKING_NOTIFY_DELETE: PACKET_ZC_PARTY_BOOKING_NOTIFY_DELETE.self,

    // | 0x810 | `clif_buyingstore_open` |
//  HEADER_ZC_OPEN_BUYING_STORE: PACKET_ZC_OPEN_BUYING_STORE.self,

    // | 0x812 | `clif_buyingstore_open_failed` |
//  HEADER_ZC_FAILED_OPEN_BUYING_STORE_TO_BUYER: PACKET_ZC_FAILED_OPEN_BUYING_STORE_TO_BUYER.self,

    // | 0x813 | `clif_buyingstore_myitemlist` |
    HEADER_ZC_MYITEMLIST_BUYING_STORE: PACKET_ZC_MYITEMLIST_BUYING_STORE.self,

    // | 0x814 | `clif_buyingstore_entry` |
    HEADER_ZC_BUYING_STORE_ENTRY: PACKET_ZC_BUYING_STORE_ENTRY.self,

    // | 0x816 | `clif_buyingstore_disappear_entry` |
    HEADER_ZC_DISAPPEAR_BUYING_STORE_ENTRY: PACKET_ZC_DISAPPEAR_BUYING_STORE_ENTRY.self,

    // | 0x818 | `clif_buyingstore_itemlist` |
    HEADER_ZC_ACK_ITEMLIST_BUYING_STORE: PACKET_ZC_ACK_ITEMLIST_BUYING_STORE.self,

    // | 0x81a | `clif_buyingstore_trade_failed_buyer` |
//  HEADER_ZC_FAILED_TRADE_BUYING_STORE_TO_BUYER: PACKET_ZC_FAILED_TRADE_BUYING_STORE_TO_BUYER.self,

    // | 0x81b, 0x9e6 | `clif_buyingstore_update_item` |
    packet_header_buyingStoreUpdateItemType: PACKET_ZC_UPDATE_ITEM_FROM_BUYING_STORE.self,

    // | 0x81c | `clif_buyingstore_delete_item` |
//  HEADER_ZC_ITEM_DELETE_BUYING_STORE: PACKET_ZC_ITEM_DELETE_BUYING_STORE.self,

    // | 0x81d | `clif_elemental_info` |
//  HEADER_ZC_EL_INIT: PACKET_ZC_EL_INIT.self,

    // | 0x81e | `clif_elemental_updatestatus` |
    HEADER_ZC_EL_PAR_CHANGE: PACKET_ZC_EL_PAR_CHANGE.self,

    // | 0x824 | `clif_buyingstore_trade_failed_seller` |
    HEADER_ZC_FAILED_TRADE_BUYING_STORE_TO_SELLER: PACKET_ZC_FAILED_TRADE_BUYING_STORE_TO_SELLER.self,

    // | 0x836, 0xb64 | `clif_search_store_info_ack` |
    HEADER_ZC_SEARCH_STORE_INFO_ACK: PACKET_ZC_SEARCH_STORE_INFO_ACK.self,

    // | 0x837 | `clif_search_store_info_failed` |
    HEADER_ZC_SEARCH_STORE_INFO_FAILED: PACKET_ZC_SEARCH_STORE_INFO_FAILED.self,

    // | 0x83a | `clif_open_search_store_info` |
    HEADER_ZC_OPEN_SEARCH_STORE_INFO: PACKET_ZC_OPEN_SEARCH_STORE_INFO.self,

    // | 0x83d | `clif_search_store_info_click_ack` |
    HEADER_ZC_SSILIST_ITEM_CLICK_ACK: PACKET_ZC_SSILIST_ITEM_CLICK_ACK.self,

    // | 0x845, 0xa2b, 0xb6e | `clif_cashshop_open` |
    HEADER_ZC_SE_CASHSHOP_OPEN: PACKET_ZC_SE_CASHSHOP_OPEN.self,

    // | 0x849 | `clif_cashshop_result` |
    HEADER_ZC_SE_PC_BUY_CASHITEM_RESULT: PACKET_ZC_SE_PC_BUY_CASHITEM_RESULT.self,

    // | 0x8b3 | `clif_showscript` |
//  HEADER_ZC_SHOWSCRIPT: PACKET_ZC_SHOWSCRIPT.self,

    // | 0x8c0 | `clif_parse_CashShopReqTab` |
    HEADER_ZC_ACK_SE_CASH_ITEM_LIST2: PACKET_ZC_ACK_SE_CASH_ITEM_LIST2.self,

    // | 0x8ca | `clif_cashshop_list` |
    HEADER_ZC_ACK_SCHEDULER_CASHITEM: PACKET_ZC_ACK_SCHEDULER_CASHITEM.self,

    // | 0x8cb, 0x97b | `clif_display_pinfo` |
    HEADER_ZC_PERSONAL_INFOMATION: PACKET_ZC_PERSONAL_INFOMATION.self,

    // | 0x8cf | `clif_spiritcharm`, `clif_spiritcharm_single` |
    HEADER_ZC_SPIRITS_ATTRIBUTE: PACKET_ZC_SPIRITS_ATTRIBUTE.self,

    // | 0x8d2 | `clif_snap` |
//  HEADER_ZC_FASTMOVE: PACKET_ZC_FASTMOVE.self,

    // | 0x8d6 | `clif_scriptclear` |
    HEADER_ZC_CLEAR_DIALOG: PACKET_ZC_CLEAR_DIALOG.self,

    // | 0x8fe | `clif_quest_add` |
//  packet_header_questUpdateType2: PACKET_ZC_HUNTING_QUEST_INFO.self,

    // | 0x8ff, 0x984 | `clif_efst_status_change` |
    HEADER_ZC_EFST_SET_ENTER: PACKET_ZC_EFST_SET_ENTER.self,

    // | 0x908 | `clif_favorite_item` |
    HEADER_ZC_INVENTORY_TAB: PACKET_ZC_INVENTORY_TAB.self,

    // | 0x90e | `clif_bg_queue_entry_init` |
    HEADER_ZC_ENTRY_QUEUE_INIT: PACKET_ZC_ENTRY_QUEUE_INIT.self,

    // | 0x96d | `clif_merge_item_open` |
    HEADER_ZC_MERGE_ITEM_OPEN: PACKET_ZC_MERGE_ITEM_OPEN.self,

    // | 0x96f | `clif_merge_item_ack` |
    HEADER_ZC_ACK_MERGE_ITEM: PACKET_ZC_ACK_MERGE_ITEM.self,

    // | 0x977 | `clif_monster_hp_bar` |
//  packet_header_monsterhpType: PACKET_ZC_HP_INFO.self,

    // | 0x97d, 0xaf6 | `clif_ranklist` |
    HEADER_ZC_ACK_RANKING: PACKET_ZC_ACK_RANKING.self,

    // | 0x97e | `clif_update_rankingpoint` |
    HEADER_ZC_UPDATE_RANKING_POINT: PACKET_ZC_UPDATE_RANKING_POINT.self,

    // | 0x988 | `clif_clan_onlinecount` |
    HEADER_ZC_NOTIFY_CLAN_CONNECTINFO: PACKET_ZC_NOTIFY_CLAN_CONNECTINFO.self,

    // | 0x989 | `clif_clan_leave` |
    HEADER_ZC_ACK_CLAN_LEAVE: PACKET_ZC_ACK_CLAN_LEAVE.self,

    // | 0x98a | `clif_clan_basicinfo` |
    HEADER_ZC_CLANINFO: PACKET_ZC_CLANINFO.self,

    // | 0x98e | `clif_clan_message` |
    HEADER_ZC_NOTIFY_CLAN_CHAT: PACKET_ZC_NOTIFY_CLAN_CHAT.self,

    // | 0x9a6 | `clif_Bank_Check` |
    HEADER_ZC_BANKING_CHECK: PACKET_ZC_BANKING_CHECK.self,

    // | 0x9a8 | `clif_bank_deposit` |
    HEADER_ZC_ACK_BANKING_DEPOSIT: PACKET_ZC_ACK_BANKING_DEPOSIT.self,

    // | 0x9aa | `clif_bank_withdraw` |
    HEADER_ZC_ACK_BANKING_WITHDRAW: PACKET_ZC_ACK_BANKING_WITHDRAW.self,

    // | 0x9ad | `clif_sale_search_reply` |
    HEADER_ZC_ACK_CASH_BARGAIN_SALE_ITEM_INFO: PACKET_ZC_ACK_CASH_BARGAIN_SALE_ITEM_INFO.self,

    // | 0x9b2 | `clif_sale_start` |
    HEADER_ZC_NOTIFY_BARGAIN_SALE_SELLING: PACKET_ZC_NOTIFY_BARGAIN_SALE_SELLING.self,

    // | 0x9b3 | `clif_sale_end` |
    HEADER_ZC_NOTIFY_BARGAIN_SALE_CLOSE: PACKET_ZC_NOTIFY_BARGAIN_SALE_CLOSE.self,

    // | 0x9b7 | `clif_bank_open` |
    HEADER_ZC_ACK_OPEN_BANKING: PACKET_ZC_ACK_OPEN_BANKING.self,

    // | 0x9b9 | `clif_bank_close` |
    HEADER_ZC_ACK_CLOSE_BANKING: PACKET_ZC_ACK_CLOSE_BANKING.self,

    // | 0x9c1 | `clif_crimson_marker` |
    HEADER_ZC_C_MARKERINFO: PACKET_ZC_C_MARKERINFO.self,

    // | 0x9c4 | `clif_sale_amount` |
    HEADER_ZC_ACK_COUNT_BARGAIN_SALE_ITEM: PACKET_ZC_ACK_COUNT_BARGAIN_SALE_ITEM.self,

    // | 0x9cd | `clif_msg_color` |
    HEADER_ZC_MSG_COLOR: PACKET_ZC_MSG_COLOR.self,

    // | 0x9d5, 0xb7a | `clif_npc_market_open` |
    HEADER_ZC_NPC_MARKET_OPEN: PACKET_ZC_NPC_MARKET_OPEN.self,

    // | 0x9d7, 0xb4e | `clif_npc_market_purchase_ack` |
    HEADER_ZC_NPC_MARKET_PURCHASE_RESULT: PACKET_ZC_NPC_MARKET_PURCHASE_RESULT.self,

    // | 0x9da | `clif_guild_storage_log` |
    HEADER_ZC_ACK_GUILDSTORAGE_LOG: PACKET_ZC_ACK_GUILDSTORAGE_LOG.self,

    // | 0x9e7 | `clif_Mail_new` |
    packet_header_rodexicon: PACKET_ZC_NOTIFY_UNREADMAIL.self,

    // | 0x9f0, 0xa7d, 0xac2 | `clif_Mail_refreshinbox` |
//  packet_header_rodexmailList: PACKET_ZC_ACK_MAIL_LIST.self,

    // | 0x9eb, 0xb63 | `clif_Mail_read` |
    HEADER_ZC_ACK_READ_RODEX: PACKET_ZC_ACK_READ_RODEX.self,

    // | 0x9ed | `clif_Mail_send` |
    packet_header_rodexwriteresult: PACKET_ZC_WRITE_MAIL_RESULT.self,

    // | 0x9f6 | `clif_mail_delete` |
    packet_header_rodexdelete: PACKET_ZC_ACK_DELETE_MAIL.self,

    // | 0x9f2 | `clif_mail_getattachment` |
    packet_header_rodexgetzeny: PACKET_ZC_ACK_ITEM_FROM_MAIL.self,

    // | 0x9f4 | `clif_mail_getattachment` |
    packet_header_rodexgetitem: PACKET_ZC_ACK_ITEM_FROM_MAIL.self,

    // | 0xa02 | `clif_dressing_room` |
    HEADER_ZC_DRESSROOM_OPEN: PACKET_ZC_DRESSROOM_OPEN.self,

    // | 0xa05, 0xb3f | `clif_Mail_setattachment` |
    HEADER_ZC_ACK_ADD_ITEM_RODEX: PACKET_ZC_ACK_ADD_ITEM_RODEX.self,

    // | 0xa07 | `clif_mail_removeitem` |
//  packet_header_rodexremoveitem: PACKET_ZC_ACK_REMOVE_RODEX_ITEM.self,

    // | 0xa12 | `clif_send_Mail_beginwrite_ack` |
    packet_header_rodexopenwrite: PACKET_ZC_ACK_OPEN_WRITE_MAIL.self,

    // | 0xa14, 0xa51 | `clif_Mail_Receiver_Ack` |
    HEADER_ZC_CHECKNAME: PACKET_ZC_CHECKNAME.self,

    // | 0xa15 |
    HEADER_ZC_GOLDPCCAFE_POINT: PACKET_ZC_GOLDPCCAFE_POINT.self,

    // | 0xa17 | `clif_dynamicnpc_result` |
    HEADER_ZC_DYNAMICNPC_CREATE_RESULT: PACKET_ZC_DYNAMICNPC_CREATE_RESULT.self,

    // | 0xa1e |
    HEADER_ZC_ACK_CLOSE_ROULETTE: PACKET_ZC_ACK_CLOSE_ROULETTE.self,

    // | 0xa23 | `clif_achievement_list_all` |
    packet_header_achievementListType: PACKET_ZC_ALL_ACH_LIST.self,

    // | 0xa24 | `clif_achievement_update` |
    packet_header_achievementUpdateType: PACKET_ZC_ACH_UPDATE.self,

    // | 0xa26 | `clif_achievement_reward_ack` |
//  packet_header_achievementRewardAckType: PACKET_ZC_REQ_ACH_REWARD_ACK.self,

    // | 0xa28 | `clif_openvending_ack` |
    HEADER_ZC_ACK_OPENSTORE2: PACKET_ZC_ACK_OPENSTORE2.self,

    // | 0xa32 |
//  0xa32: PACKET_ZC_OPEN_RODEX_THROUGH_NPC_ONLY.self,

    // | 0xa38, 0xae2 | `clif_ui_open` |
    HEADER_ZC_UI_OPEN: PACKET_ZC_UI_OPEN.self,

    // | 0xa3b | `clif_hat_effects`, `clif_hat_effect_single` |
    HEADER_ZC_EQUIPMENT_EFFECT: PACKET_ZC_EQUIPMENT_EFFECT.self,

    // | 0xa3f |
    HEADER_ZC_UPDATE_CARDSLOT: PACKET_ZC_UPDATE_CARDSLOT.self,

    // | 0xa41 | `clif_skill_scale` |
    packet_header_skillscale: PACKET_ZC_SKILL_SCALE.self,

    // | 0xa47 | `clif_stylist_response` |
    HEADER_ZC_STYLE_CHANGE_RES: PACKET_ZC_STYLE_CHANGE_RES.self,

    // | 0xa4e | `clif_laphine_synthesis_open` |
    HEADER_ZC_RANDOM_COMBINE_ITEM_UI_OPEN: PACKET_ZC_RANDOM_COMBINE_ITEM_UI_OPEN.self,

    // | 0xa50 | `clif_laphine_synthesis_result` |
    HEADER_ZC_ACK_RANDOM_COMBINE_ITEM: PACKET_ZC_ACK_RANDOM_COMBINE_ITEM.self,

    // | 0xa53 | `clif_captcha_upload_request` |
    HEADER_ZC_ACK_UPLOAD_MACRO_DETECTOR: PACKET_ZC_ACK_UPLOAD_MACRO_DETECTOR.self,

    // | 0xa55 | `clif_captcha_upload_end` |
    HEADER_ZC_COMPLETE_UPLOAD_MACRO_DETECTOR_CAPTCHA: PACKET_ZC_COMPLETE_UPLOAD_MACRO_DETECTOR_CAPTCHA.self,

    // | 0xa57 | `clif_macro_reporter_status` |
    HEADER_ZC_ACK_APPLY_MACRO_DETECTOR: PACKET_ZC_ACK_APPLY_MACRO_DETECTOR.self,

    // | 0xa58 | `clif_macro_detector_request` |
    HEADER_ZC_APPLY_MACRO_DETECTOR: PACKET_ZC_APPLY_MACRO_DETECTOR.self,

    // | 0xa59 | `clif_macro_detector_request` |
    HEADER_ZC_APPLY_MACRO_DETECTOR_CAPTCHA: PACKET_ZC_APPLY_MACRO_DETECTOR_CAPTCHA.self,

    // | 0xa5b | `clif_macro_detector_request_show` |
    HEADER_ZC_REQ_ANSWER_MACRO_DETECTOR: PACKET_ZC_REQ_ANSWER_MACRO_DETECTOR.self,

    // | 0xa5d | `clif_macro_detector_status` |
    HEADER_ZC_CLOSE_MACRO_DETECTOR: PACKET_ZC_CLOSE_MACRO_DETECTOR.self,

    // | 0xa6a | `clif_captcha_preview_response` |
    HEADER_ZC_ACK_PREVIEW_MACRO_DETECTOR: PACKET_ZC_ACK_PREVIEW_MACRO_DETECTOR.self,

    // | 0xa6b | `clif_captcha_preview_response` |
    HEADER_ZC_PREVIEW_MACRO_DETECTOR_CAPTCHA: PACKET_ZC_PREVIEW_MACRO_DETECTOR_CAPTCHA.self,

    // | 0xa6d | `clif_macro_reporter_select` |
    HEADER_ZC_ACK_PLAYER_AID_IN_RANGE: PACKET_ZC_ACK_PLAYER_AID_IN_RANGE.self,

    // | 0xa78 | `clif_camerainfo` |
    HEADER_ZC_VIEW_CAMERAINFO: PACKET_ZC_VIEW_CAMERAINFO.self,

    // | 0xa98 | `clif_equipswitch_add` |
//  HEADER_ZC_REQ_WEAR_SWITCHEQUIP_ADD_RESULT: PACKET_ZC_REQ_WEAR_SWITCHEQUIP_ADD_RESULT.self,

    // | 0xa9a | `clif_equipswitch_remove` |
//  HEADER_ZC_REQ_WEAR_SWITCHEQUIP_REMOVE_RESULT: PACKET_ZC_REQ_WEAR_SWITCHEQUIP_REMOVE_RESULT.self,

    // | 0xa9b | `clif_equipswitch_list` |
    HEADER_ZC_SEND_SWAP_EQUIPITEM_INFO: PACKET_ZC_SEND_SWAP_EQUIPITEM_INFO.self,

    // | 0xa9d | `clif_equipswitch_reply` |
//  HEADER_ZC_REQ_FULLSWITCH_RESULT: PACKET_ZC_REQ_FULLSWITCH_RESULT.self,

    // | 0xaa0 | `clif_refineui_open` |
    HEADER_ZC_OPEN_REFINING_UI: PACKET_ZC_OPEN_REFINING_UI.self,

    // | 0xaa2 | `clif_refineui_info` |
    HEADER_ZC_REFINING_MATERIAL_LIST: PACKET_ZC_REFINING_MATERIAL_LIST.self,

    // | 0xaa7 |
    HEADER_ZC_MOVE_ITEM_FAILED: PACKET_ZC_MOVE_ITEM_FAILED.self,

    // | 0xab2 | `clif_party_dead` |
    HEADER_ZC_GROUP_ISALIVE: PACKET_ZC_GROUP_ISALIVE.self,

    // | 0xab4 | `clif_laphine_upgrade_open` |
    HEADER_ZC_RANDOM_UPGRADE_ITEM_UI_OPEN: PACKET_ZC_RANDOM_UPGRADE_ITEM_UI_OPEN.self,

    // | 0xab7 | `clif_laphine_upgrade_result` |
    HEADER_ZC_ACK_RANDOM_UPGRADE_ITEM: PACKET_ZC_ACK_RANDOM_UPGRADE_ITEM.self,

    // | 0xab9, 0xb13, 0xb43 | `clif_item_preview` |
    HEADER_ZC_CHANGE_ITEM_OPTION: PACKET_ZC_CHANGE_ITEM_OPTION.self,

    // | 0xabd | `clif_party_job_and_level` |
    HEADER_ZC_NOTIFY_MEMBERINFO_TO_GROUPM: PACKET_ZC_NOTIFY_MEMBERINFO_TO_GROUPM.self,

    // | 0xacb | `clif_longlongpar_change` |
    HEADER_ZC_LONGLONGPAR_CHANGE: PACKET_ZC_LONGLONGPAR_CHANGE.self,

    // | 0xada | `clif_broadcast_refine_result` |
    HEADER_ZC_BROADCAST_ITEMREFINING_RESULT: PACKET_ZC_BROADCAST_ITEMREFINING_RESULT.self,

    // | 0xadb |
    HEADER_ZC_DEBUGMSG: PACKET_ZC_DEBUGMSG.self,

    // | 0xade | `clif_weight_limit` |
    HEADER_ZC_RECOVER_PENALTY_OVERWEIGHT: PACKET_ZC_RECOVER_PENALTY_OVERWEIGHT.self,

    // | 0xae7 | `clif_partybooking_ask` |
    HEADER_ZC_PARTY_REQ_MASTER_TO_JOIN: PACKET_ZC_PARTY_REQ_MASTER_TO_JOIN.self,

    // | 0xaf6 | `clif_ranklist` |
    HEADER_ZC_ACK_RANKING2: PACKET_ZC_ACK_RANKING2.self,

    // | 0xafa | `clif_partybooking_reply` |
    HEADER_ZC_PARTY_JOIN_REQ_ACK_FROM_MASTER: PACKET_ZC_PARTY_JOIN_REQ_ACK_FROM_MASTER.self,

    // | 0xafd | `clif_guild_position_selected` |
    HEADER_ZC_GUILD_POSITION: PACKET_ZC_GUILD_POSITION.self,

    // | 0xb08 | `clif_inventoryStart` |
    HEADER_ZC_INVENTORY_START: PACKET_ZC_INVENTORY_START.self,

    // | 0xb0b | `clif_inventoryEnd` |
    HEADER_ZC_INVENTORY_END: PACKET_ZC_INVENTORY_END.self,

    // | 0xb0d | `clif_specialeffect_remove` |
    HEADER_ZC_REMOVE_EFFECT: PACKET_ZC_REMOVE_EFFECT.self,

    // | 0xb0e, 0xb78 | `clif_barter_open` |
    HEADER_ZC_NPC_BARTER_MARKET_ITEMINFO: PACKET_ZC_NPC_BARTER_MARKET_ITEMINFO.self,

    // | 0xb1b | `clif_loadConfirm` |
    HEADER_ZC_NOTIFY_ACTORINIT: PACKET_ZC_NOTIFY_ACTORINIT.self,

    // | 0xb15 | `clif_inventory_expansion_response` |
    HEADER_ZC_ACK_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE: PACKET_ZC_ACK_OPEN_MSGBOX_EXTEND_BODYITEM_SIZE.self,

    // | 0xb17 | `clif_inventory_expansion_result` |
    HEADER_ZC_ACK_EXTEND_BODYITEM_SIZE: PACKET_ZC_ACK_EXTEND_BODYITEM_SIZE.self,

    // | 0xb18 | `clif_inventory_expansion_info` |
    HEADER_ZC_EXTEND_BODYITEM_SIZE: PACKET_ZC_EXTEND_BODYITEM_SIZE.self,

    // | 0xb1d | `clif_ping` |
    HEADER_ZC_PING_LIVE: PACKET_ZC_PING_LIVE.self,

    // | 0xb25 |
//  HEADER_ZC_PAR_4JOB_CHANGE: PACKET_ZC_PAR_4JOB_CHANGE.self,

    // | 0xb27 | `clif_guild_castle_list` |
    HEADER_ZC_GUILD_AGIT_INFO: PACKET_ZC_GUILD_AGIT_INFO.self,

    // | 0xb2d | `clif_guild_castleinfo` |
    HEADER_ZC_REQ_ACK_AGIT_INVESTMENT: PACKET_ZC_REQ_ACK_AGIT_INVESTMENT.self,

    // | 0xb2e | `clif_guild_castle_teleport_res` |
    HEADER_ZC_REQ_ACK_MOVE_GUILD_AGIT: PACKET_ZC_REQ_ACK_MOVE_GUILD_AGIT.self,

    // | 0xb56, 0xb79 | `clif_barter_extended_open` |
    HEADER_ZC_NPC_EXPANDED_BARTER_MARKET_ITEMINFO: PACKET_ZC_NPC_EXPANDED_BARTER_MARKET_ITEMINFO.self,

    // | 0xb5a | `clif_enchantgrade_add` |
    HEADER_ZC_GRADE_ENCHANT_MATERIAL_LIST: PACKET_ZC_GRADE_ENCHANT_MATERIAL_LIST.self,

    // | 0xb5d | `clif_enchantgrade_result` |
    HEADER_ZC_GRADE_ENCHANT_ACK: PACKET_ZC_GRADE_ENCHANT_ACK.self,

    // | 0xb5e | `clif_enchantgrade_announce` |
    HEADER_ZC_GRADE_ENCHANT_BROADCAST_RESULT: PACKET_ZC_GRADE_ENCHANT_BROADCAST_RESULT.self,

    // | 0xb68 | `clif_enchantingshadow_spirit` |
    HEADER_ZC_TARGET_SPIRITS: PACKET_ZC_TARGET_SPIRITS.self,

    // | 0xb6b | `clif_summon_init` |
    HEADER_ZC_SUMMON_HP_INIT: PACKET_ZC_SUMMON_HP_INIT.self,

    // | 0xb6c | `clif_summon_hp_bar` |
    HEADER_ZC_SUMMON_HP_UPDATE: PACKET_ZC_SUMMON_HP_UPDATE.self,

    // | 0xb73 | `clif_soulball` |
    HEADER_ZC_SOULENERGY: PACKET_ZC_SOULENERGY.self,

    // | 0xb8d | `clif_reputation_list`, `clif_reputation_type` |
    HEADER_ZC_REPUTE_INFO: PACKET_ZC_REPUTE_INFO.self,

    // | 0xb8f | `clif_item_reform_open` |
    HEADER_ZC_OPEN_REFORM_UI: PACKET_ZC_OPEN_REFORM_UI.self,

    // | 0xb92 | `clif_item_reform_result` |
    HEADER_ZC_ITEM_REFORM_ACK: PACKET_ZC_ITEM_REFORM_ACK.self,

    // | 0xb9a | `clif_enchantwindow_open` |
    HEADER_ZC_UI_OPEN_V3: PACKET_ZC_UI_OPEN_V3.self,

    // | 0xb9f | `clif_enchantwindow_result` |
    HEADER_ZC_RESPONSE_ENCHANT: PACKET_ZC_RESPONSE_ENCHANT.self,

    // | 0xba1 | `clif_set_dialog_align` |
    HEADER_ZC_DIALOG_TEXT_ALIGN: PACKET_ZC_DIALOG_TEXT_ALIGN.self,

    // | 0xbae | `clif_unequipall_reply` |
    HEADER_ZC_ACK_TAKEOFF_EQUIP_ALL: PACKET_ZC_ACK_TAKEOFF_EQUIP_ALL.self,

    // | 0xc0c | `clif_macro_checker` |
    HEADER_ZC_GM_CHECKER: PACKET_ZC_GM_CHECKER.self,
]
