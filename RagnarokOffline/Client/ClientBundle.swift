//
//  ClientBundle.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

class ClientBundle {
    static let shared = ClientBundle()

    let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let grf: GRFWrapper

    init() {
        grf = GRFWrapper(url: url.appendingPathComponent("data.grf"))
    }
}
