//
//  SidebarRow.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/24.
//

import SwiftUI

struct SidebarRow: View {
    var titleKey: LocalizedStringKey
    var iconName: String
    var iconColor: Color

    var body: some View {
        Label {
            Text(titleKey)
        } icon: {
            SidebarIcon(name: iconName, color: iconColor)
        }
    }

    init(_ titleKey: LocalizedStringKey, iconName: String, iconColor: Color) {
        self.titleKey = titleKey
        self.iconName = iconName
        self.iconColor = iconColor
    }
}

#Preview {
    List {
        SidebarRow("Settings", iconName: "gear", iconColor: .gray)
    }
}
