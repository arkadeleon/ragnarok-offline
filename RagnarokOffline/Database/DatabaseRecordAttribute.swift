//
//  DatabaseRecordAttribute.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import Foundation

struct DatabaseRecordAttribute: Identifiable {
    var name: LocalizedStringResource
    var value: String

    var id: String {
        name.key
    }

    init(name: LocalizedStringResource, value: String) {
        self.name = name
        self.value = value
    }

    init(name: LocalizedStringResource, value: Bool) {
        self.name = name
        self.value = value ? String(localized: "Yes") : String(localized: "No")
    }

    init(name: LocalizedStringResource, value: Int) {
        self.name = name
        self.value = value.formatted()
    }

    init(name: LocalizedStringResource, value: Double) {
        self.name = name
        self.value = value.formatted()
    }

    init(name: LocalizedStringResource, value resource: LocalizedStringResource) {
        self.name = name
        self.value = String(localized: resource)
    }
}
