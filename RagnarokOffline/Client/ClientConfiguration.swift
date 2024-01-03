//
//  ClientConfiguration.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

class ClientConfiguration {
    static let shared = ClientConfiguration()

    let encoding: String.Encoding = Encoding.gb_18030_2000.swiftStringEncoding
}
