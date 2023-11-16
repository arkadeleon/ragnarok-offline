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

    let file: DocumentWrapper

    init(file: DocumentWrapper) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let contentViewController = switch file.contentType {
        case .txt, .xml, .ini, .lua, .lub:
            UIHostingController(rootView: TextDocumentView(document: file))
        case .bmp, .png, .jpg, .tga, .ebm, .pal:
            UIHostingController(rootView: ImageDocumentView(document: file))
        case .mp3, .wav:
            UIHostingController(rootView: AudioDocumentView(document: file))
        case .spr:
            UIHostingController(rootView: SpriteDocumentView(document: file))
        case .act:
            ACTPreviewViewController(document: file)
        case .rsm:
            UIHostingController(rootView: ModelDocumentView(document: file))
        case .rsw:
            UIHostingController(rootView: WorldDocumentView(document: file))
        default:
            UIViewController()
        }

        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        contentViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        contentViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
