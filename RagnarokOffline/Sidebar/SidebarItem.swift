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
            return "Client"
        case .server:
            return "Server"
        case .database:
            return "Database"
        case .weapons:
            return "Weapons"
        case .armors:
            return "Armors"
        case .cards:
            return "Cards"
        case .items:
            return "Items"
        case .monsters:
            return "Monsters"
        case .skills:
            return "Skills"
        }
    }
}
