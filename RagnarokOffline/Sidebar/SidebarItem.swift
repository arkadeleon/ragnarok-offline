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
            return NSLocalizedString("Client", value: "Client", comment: "")
        case .server:
            return NSLocalizedString("Server", value: "Server", comment: "")
        case .database:
            return NSLocalizedString("Database", value: "Database", comment: "")
        case .weapons:
            return NSLocalizedString("Weapons", value: "Weapons", comment: "")
        case .armors:
            return NSLocalizedString("Armors", value: "Armors", comment: "")
        case .cards:
            return NSLocalizedString("Cards", value: "Cards", comment: "")
        case .items:
            return NSLocalizedString("Items", value: "Items", comment: "")
        case .monsters:
            return NSLocalizedString("Monsters", value: "Monsters", comment: "")
        case .skills:
            return NSLocalizedString("Skills", value: "Skills", comment: "")
        }
    }
}
