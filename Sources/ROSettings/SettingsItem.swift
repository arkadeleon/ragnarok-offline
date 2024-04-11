//
//  SettingsItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/29.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import Foundation

@propertyWrapper
public struct SettingsItem<Value> {
    public let key: String
    public let defaultValue: Value

    public var wrappedValue: Value {
        get {
            value()
        }
        set {
            setValue(newValue)
        }
    }

    public init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    private func value() -> Value {
        switch defaultValue {
        case let rawRepresentable as any RawRepresentable<String>:
            if let value = UserDefaults.standard.value(forKey: key) as? String {
                type(of: rawRepresentable).init(rawValue: value) as? Value ?? defaultValue
            } else {
                defaultValue
            }
        default:
            defaultValue
        }
    }

    private func setValue(_ value: Value) {
        switch value {
        case let rawRepresentable as any RawRepresentable<String>:
            UserDefaults.standard.set(rawRepresentable.rawValue, forKey: key)
        default:
            break
        }
    }
}
