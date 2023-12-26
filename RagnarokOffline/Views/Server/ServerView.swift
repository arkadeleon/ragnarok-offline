//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import SwiftUI

struct ServerView: UIViewControllerRepresentable {
    let server: RAServer

    func makeUIViewController(context: Context) -> ServerViewController {
        ServerViewController(server: server)
    }

    func updateUIViewController(_ serverViewController: ServerViewController, context: Context) {
    }
}
