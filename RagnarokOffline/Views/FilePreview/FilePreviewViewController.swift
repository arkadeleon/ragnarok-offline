//
//  FilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FilePreviewViewController: UIViewController {
    let file: File

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let type = file.type else {
            return
        }

        let contentViewController = switch type {
        case let type where type.conforms(to: .text) || type == .lua || type == .lub:
            TextFilePreviewViewController(file: file)
        case let type where type.conforms(to: .image) || type == .ebm || type == .pal:
            ImageFilePreviewViewController(file: file)
        case let type where type.conforms(to: .audio):
            AudioFilePreviewViewController(file: file)
        case .act:
            ACTPreviewViewController(file: file)
        case .gat:
            GATPreviewViewController(file: file)
        case .rsm:
            RSMPreviewViewController(file: file)
        case .rsw:
            RSWPreviewViewController(file: file)
        case .spr:
            SPRPreviewViewController(file: file)
        case .str:
            STRPreviewViewController(file: file)
        default:
            UIViewController()
        }

        addChild(contentViewController)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
