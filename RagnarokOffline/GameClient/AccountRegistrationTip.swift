//
//  AccountRegistrationTip.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/13.
//

import SwiftUI
import TipKit

struct AccountRegistrationTip: Tip {
    var title: Text {
        Text("Account Registration")
    }

    var message: Text? {
        Text("Use _M/_F to register new accounts on the server.")
    }

    var image: Image? {
        Image(systemName: "person.badge.plus")
    }
}
