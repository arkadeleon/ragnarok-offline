//
//  FilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//

import SwiftUI
import UIKit
import ROFileSystem

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
            UIHostingController(rootView: TextFilePreviewView(file: file))
        case let type where type.conforms(to: .image) || type == .ebm || type == .pal:
            UIHostingController(rootView: ImageFilePreviewView(file: file))
        case let type where type.conforms(to: .audio):
            UIHostingController(rootView: AudioFilePreviewView(file: file))
        case .act:
            UIHostingController(rootView: ACTFilePreviewView(file: file))
        case .gat:
            UIHostingController(rootView: GATFilePreviewView(file: file))
        case .rsm:
            UIHostingController(rootView: RSMFilePreviewView(file: file))
        case .rsw:
            RSWPreviewViewController(file: file)
        case .spr:
            UIHostingController(rootView: SPRFilePreviewView(file: file))
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
