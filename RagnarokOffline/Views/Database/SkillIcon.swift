//
//  SkillIcon.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/2.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI

struct SkillIcon: View {
    let skillName: String

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        ZStack {
            switch phase {
            case .empty:
                EmptyView()
            case .success(let image):
                image
            case .failure(let error):
                EmptyView()
            @unknown default:
                fatalError()
            }
        }
        .frame(width: 24, height: 24)
        .task {
            if let image = await ClientResourceManager.shared.skillIconImage(skillName) {
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(NSError())
            }
        }
    }
}
