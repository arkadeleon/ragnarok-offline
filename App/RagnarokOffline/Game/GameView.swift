//
//  GameView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//

import SwiftUI

struct GameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        GameViewController()
    }

    func updateUIViewController(_ gameViewController: GameViewController, context: Context) {
    }
}
