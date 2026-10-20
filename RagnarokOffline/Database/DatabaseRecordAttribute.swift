//
//  DatabaseRecordAttribute.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI

struct DatabaseRecordAttribute: Identifiable {
    var name: LocalizedStringResource
    var value: String
    var valueColor: Color?

    var id: String {
        name.key
    }

    init(name: LocalizedStringResource, value: String, valueColor: Color? = nil) {
        self.name = name
        self.value = value
        self.valueColor = valueColor
    }

    init(name: LocalizedStringResource, value: Bool) {
        self.name = name
        self.value = value ? String(localized: LocalizedStringResource("Yes", table: "Database")) : String(localized: LocalizedStringResource("No", table: "Database"))
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
