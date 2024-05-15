//
//  CubeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/15.
//

import SwiftUI

struct CubeView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CubeViewController {
        CubeViewController()
    }

    func updateUIViewController(_ cubeViewController: CubeViewController, context: Context) {
    }
}

#Preview {
    CubeView()
}
