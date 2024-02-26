//
//  ClientSettings.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/3.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

class ClientSettings {
    static let shared = ClientSettings()

    private let textEncodingKey = "client_text_encoding"

    var textEncoding: TextEncoding {
        didSet {
            UserDefaults.standard.setValue(textEncoding.rawValue, forKey: textEncodingKey)
        }
    }

    init() {
        textEncoding = UserDefaults.standard.string(forKey: textEncodingKey).flatMap(TextEncoding.init) ?? .default
    }
}
