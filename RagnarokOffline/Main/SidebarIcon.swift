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
        #if os(macOS)
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 20, height: 20)
            .overlay {
                Image(systemName: name)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
            }
        #else
        RoundedRectangle(cornerRadius: 6.5)
            .fill(color)
            .frame(width: 29, height: 29)
            .overlay {
                Image(systemName: name)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
        #endif
    }
}

#Preview {
    SidebarIcon(name: "folder", color: .blue)
}
