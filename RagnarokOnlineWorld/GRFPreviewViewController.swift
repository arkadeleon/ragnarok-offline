//
//  GRFPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/6.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class GRFPreviewViewController: UITableViewController {

    var entries: [GRFDocument.Entry]!

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data.grf")
            let grf = try GRFDocument(url: url)
            entries = grf.entries
            tableView.reloadData()
        } catch let error {
            print(error)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "EntryCell")
        cell.textLabel?.text = entries[indexPath.row].filename
        cell.detailTextLabel?.text = String(entries[indexPath.row].realSize)
        return cell
    }
}
