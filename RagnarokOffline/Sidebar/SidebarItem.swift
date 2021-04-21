//
//  SidebarItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/1.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

enum SidebarItem: Hashable {
    case header(String)
    case client
    case server
    case weapons
    case armors
    case cards
    case items
    case monsters

    var title: String {
        switch self {
        case .header(let title):
            return title
        case .client:
            return Strings.client
        case .server:
            return Strings.server
        case .weapons:
            return Strings.weapons
        case .armors:
            return Strings.armors
        case .cards:
            return Strings.cards
        case .items:
            return Strings.items
        case .monsters:
            return Strings.monsters
        }
    }
}
