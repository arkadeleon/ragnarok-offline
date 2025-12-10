//
//  SidebarIcon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/24.
//

import SwiftUI

struct SidebarIcon: View {
    var name: String
    var color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 6.5)
            .fill(color)
            .frame(width: 29, height: 29)
            .overlay {
                Image(systemName: name)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    SidebarIcon(name: "folder", color: .blue)
}
