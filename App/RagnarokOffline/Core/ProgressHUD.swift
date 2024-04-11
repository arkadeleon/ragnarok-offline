//
//  ProgressHUD.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/7.
//

import SwiftUI

struct ProgressHUD: View {
    var body: some View {
        ProgressView()
            .controlSize(.large)
            .frame(width: 80, height: 80)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProgressHUD()
}
