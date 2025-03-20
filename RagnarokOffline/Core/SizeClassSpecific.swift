//
//  SizeClassSpecific.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/20.
//

import SwiftUI

func hSpacing(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
    sizeClass == .compact ? 16 : 32
}

func vSpacing(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
    sizeClass == .compact ? 32 : 64
}

func searchFieldPlacement(_ sizeClass: UserInterfaceSizeClass?) -> SearchFieldPlacement {
    #if os(macOS)
    .automatic
    #else
    if sizeClass == .compact {
        .navigationBarDrawer(displayMode: .always)
    } else {
        .automatic
    }
    #endif
}
