//
//  AudioPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPreviewViewController: UIViewController {

    let source: DocumentSource

    private var player: AVAudioPlayer?

    init(source: DocumentSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = source.name

        view.backgroundColor = .systemBackground

        loadSource()
    }

    private func loadSource() {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
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
