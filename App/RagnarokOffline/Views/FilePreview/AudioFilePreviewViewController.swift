//
//  AudioFilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/21.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import AVFoundation
import ROFileSystem

class AudioFilePreviewViewController: UIViewController {
    let file: File

    private var playButton: UIButton!
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

        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "play.circle")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 50)

        let playAction = UIAction { [weak self] _ in
            Task {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)

                if self?.player == nil {
                    guard let data = await self?.loadAudio() else {
                        return
                    }
                    self?.player = try? AVAudioPlayer(data: data)
                }

                if self?.player?.isPlaying == false {
                    self?.player?.play()
                    configuration.image = UIImage(systemName: "pause.circle")
                } else {
                    self?.player?.pause()
                    configuration.image = UIImage(systemName: "play.circle")
                }

                self?.playButton.configuration = configuration
            }
        }

        playButton = UIButton(configuration: configuration, primaryAction: playAction)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        player?.stop()
        player = nil

        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "play.circle")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 50)
        playButton.configuration = configuration
    }

    nonisolated private func loadAudio() async -> Data? {
        let data = self.file.contents()
        return data
    }
}
