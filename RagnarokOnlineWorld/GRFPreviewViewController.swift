//
//  GRFPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/6.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class GRFPreviewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.grf")
            let grf = try GRFDocument(url: url)

            let directoryViewController = GRFDirectoryViewController(grf: grf, directory: "data")
            navigationController?.pushViewController(directoryViewController, animated: true)
        } catch let error {
            print(error)
        }
    }
}
