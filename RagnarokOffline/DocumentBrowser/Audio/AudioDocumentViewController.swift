//
//  AudioDocumentViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import AVFoundation

class AudioDocumentViewController: UIViewController {

    let document: DocumentWrapper

    private var player: AVAudioPlayer?

    init(document: DocumentWrapper) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        title = document.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        loadDocumentContents()
    }

    private func loadDocumentContents() {
        DispatchQueue.global().async {
            guard let data = self.document.contents() else {
                return
            }

            DispatchQueue.main.async {
                let player = try? AVAudioPlayer(data: data)
                player?.play()

                self.player = player
            }
        }
    }
}