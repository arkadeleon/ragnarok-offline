//
//  GRFDirectoryViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/6.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class GRFDirectoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let grf: GRFDocument
    let directory: String

    lazy var items: [Item] = {
        var items: [Item] = []
        for entry in grf.entries where entry.filename.hasPrefix(directory) {
            var filename = entry.filename
            filename.removeSubrange(directory.startIndex..<directory.endIndex)
            let components = filename.split(separator: "\\")
            if components.count == 1 {
                items.append(.entry(entry))
            } else if components.count > 1 {
                let directory = self.directory.appending("\\").appending(components[0])
                items.append(.directory(directory))
            }
        }
        items = Array(Set(items))
        return items.sorted()
    }()

    private var collectionView: UICollectionView!

    init(grf: GRFDocument, directory: String) {
        self.grf = grf
        self.directory = directory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 120)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DocumentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentCell
        switch items[indexPath.row] {
        case .directory(let directory):
            cell.nameLabel.text = String(directory.split(separator: "\\").last!)
        case .entry(let entry):
            cell.nameLabel.text = String(entry.filename.split(separator: "\\").last!)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch items[indexPath.row] {
        case .directory(let directory):
            let directoryViewController = GRFDirectoryViewController(grf: grf, directory: directory)
            navigationController?.pushViewController(directoryViewController, animated: true)
        case .entry(_):
            break
        }
    }
}

extension GRFDirectoryViewController {

    enum Item: Equatable, Comparable, Hashable {
        case directory(String)
        case entry(GRFDocument.Entry)

        static func < (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case (.directory(let ldirectory), .directory(let rdirectory)):
                return ldirectory < rdirectory
            case (.directory(_), .entry(_)):
                return true
            case (.entry(_), .directory(_)):
                return false
            case (.entry(let lentry), .entry(let rentry)):
                return lentry.filename < rentry.filename
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .directory(let directory):
                directory.hash(into: &hasher)
            case .entry(let entry):
                entry.filename.hash(into: &hasher)
            }
        }
    }
}
