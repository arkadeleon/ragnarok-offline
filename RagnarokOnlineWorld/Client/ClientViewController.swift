//
//  ClientViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController {

    private var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Client"

        view.backgroundColor = .systemBackground

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        DispatchQueue.global().async {
            try? ResourceManager.default.preload()
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorView.stopAnimating()
                try? self?.addRootDocumentWrappersViewController()
            }
        }
    }

    private func addRootDocumentWrappersViewController() throws {
        let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let documentWrappersViewController = DocumentWrappersViewController(documentWrapper: .directory(url))

        addChild(documentWrappersViewController)
        documentWrappersViewController.view.frame = view.bounds
        documentWrappersViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(documentWrappersViewController.view)
        documentWrappersViewController.didMove(toParent: self)
    }
}
