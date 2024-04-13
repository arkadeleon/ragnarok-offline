//
//  Message.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/12.
//

import Foundation

struct Message: Identifiable {
    enum Sender {
        case client
        case server
    }

    var id = UUID()
    var sender: Sender
    var content: String
}
