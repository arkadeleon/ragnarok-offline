//
//  SettingsItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/29.
//

import Foundation

@propertyWrapper
struct SettingsItem<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            value()
        }
        set {
            setValue(newValue)
        }
    }

    init(_ key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    private func value() -> Value {
        switch defaultValue {
        case _ as String:
            if let value = UserDefaults.standard.value(forKey: key) as? String {
                (value as? Value) ?? defaultValue
            } else {
                defaultValue
            }
        case let rawRepresentable as any RawRepresentable<String>:
            if let value = UserDefaults.standard.value(forKey: key) as? String {
                (type(of: rawRepresentable).init(rawValue: value) as? Value) ?? defaultValue
            } else {
                defaultValue
            }
        default:
            defaultValue
        }
    }

    private func setValue(_ value: Value) {
        switch value {
        case let string as String:
            UserDefaults.standard.set(string, forKey: key)
        case let rawRepresentable as any RawRepresentable<String>:
            UserDefaults.standard.set(rawRepresentable.rawValue, forKey: key)
        default:
            break
        }
    }
}
