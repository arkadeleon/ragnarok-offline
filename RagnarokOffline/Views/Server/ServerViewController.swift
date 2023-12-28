//
//  ServerViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import rAthenaResource
import Terminal
import UIKit

class ServerViewController: UIViewController {
    let server: RAServer

    private var terminalView: TerminalView!
    private var startButton: UIButton!

    init(server: RAServer) {
        self.server = server
        super.init(nibName: nil, bundle: nil)
        title = server.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        terminalView = TerminalView()
        terminalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(terminalView)

        let configuration = UIImage.SymbolConfiguration(pointSize: 50)
        let startAction = UIAction(image: UIImage(systemName: "play", withConfiguration: configuration)) { action in
            self.startButton.isHidden = true
            Task {
                await self.server.start()
            }
        }
        startButton = UIButton(primaryAction: startAction)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isHidden = server.status != .notStarted
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            terminalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            terminalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            terminalView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            terminalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        Task {
            await configureServer()
        }
    }

    nonisolated private func configureServer() async {
        try? RAResourceManager.shared.copyResourceFilesToLibraryDirectory()

        server.outputHandler = { [weak self] data in
            if let data = String(data: data, encoding: .isoLatin1)?
                .replacingOccurrences(of: "\n", with: "\r\n")
                .data(using: .isoLatin1) {
                Task { [weak self] in
                    await self?.terminalView.appendBuffer(data)
                }
            }
        }
    }
}
