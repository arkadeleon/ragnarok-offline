//
//  AudioFilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import AVFoundation

class AudioFilePreviewViewController: UIViewController {
    let file: File

    private var player: AVAudioPlayer?

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
        title = file.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        Task {
            guard let data = await loadAudio() else {
                return
            }

            player = try? AVAudioPlayer(data: data)
            player?.play()
        }
    }

    nonisolated private func loadAudio() async -> Data? {
        let data = self.file.contents()
        return data
    }
}
