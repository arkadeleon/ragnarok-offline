//
//  JobImageView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/9.
//

import RagnarokConstants
import SwiftUI

struct JobImageView: View {
    var job: JobModel

    var body: some View {
        ZStack(alignment: .bottom) {
            if !job.animatedImagesByGender.values.contains(where: { $0.firstFrame != nil }) {
                Image(systemName: "person")
                    .font(.system(size: 50, weight: .thin))
                    .foregroundStyle(Color.secondary)
                    .frame(width: CGFloat(job.id.availableGenders.count) * 56, height: 100, alignment: .bottom)
            }

            HStack(alignment: .bottom, spacing: -12) {
                ForEach(job.id.availableGenders, id: \.self) { gender in
                    Group {
                        if let animatedImage = job.animatedImagesByGender[gender], let firstFrame = animatedImage.firstFrame {
                            Image(firstFrame, scale: animatedImage.scale, label: Text(gender.localizedName))
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 56, height: 100, alignment: .bottom)
                    .task(id: job.id) {
                        await job.fetchAnimatedImage(for: gender)
                    }
                }
            }
        }
    }
}
