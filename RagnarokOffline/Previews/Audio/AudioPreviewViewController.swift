//
//  AudioPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var player: AVAudioPlayer?

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
        title = previewItem.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard let data = try? self.previewItem.data() else {
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
