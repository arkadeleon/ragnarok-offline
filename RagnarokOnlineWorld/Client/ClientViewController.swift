//
//  ClientViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Client"

        view.backgroundColor = .systemBackground

        try? addRootDocumentItemsViewController()
    }

    private func addRootDocumentItemsViewController() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let documentItemsViewController = DocumentItemsViewController(documentItem: .directory(url))

        addChild(documentItemsViewController)
        documentItemsViewController.view.frame = view.bounds
        documentItemsViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(documentItemsViewController.view)
        documentItemsViewController.didMove(toParent: self)
    }
}
