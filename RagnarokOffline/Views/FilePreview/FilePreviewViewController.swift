//
//  FilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
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
        case let type where type.conforms(to: .text) == true || type == .lua || type == .lub:
            UIHostingController(rootView: TextDocumentView(file: file))
        case let type where type.conforms(to: .image) == true || type == .ebm || type == .pal:
            ImageDocumentViewController(file: file)
        case let type where type.conforms(to: .audio) == true:
            AudioDocumentViewController(file: file)
        case .act:
            ACTPreviewViewController(file: file)
        case .gat:
            GATPreviewViewController(file: file)
        case .rsm:
            RSMPreviewViewController(file: file)
        case .rsw:
            RSWPreviewViewController(file: file)
        case .spr:
            UIHostingController(rootView: SpriteDocumentView(file: file))
        case .str:
            STRPreviewViewController(file: file)
        default:
            UIViewController()
        }

        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
