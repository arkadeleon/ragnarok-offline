//
//  SidebarItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/1.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

enum SidebarItem: Hashable {
    case client
    case server
    case database
    case weapons
    case armors
    case cards
    case items
    case monsters
    case skills

    var title: String {
        switch self {
        case .client:
            return R.string.client
        case .server:
            return R.string.server
        case .database:
            return R.string.database
        case .weapons:
            return R.string.weapons
        case .armors:
            return R.string.armors
        case .cards:
            return R.string.cards
        case .items:
            return R.string.items
        case .monsters:
            return R.string.monsters
        case .skills:
            return R.string.skills
        }
    }
}
