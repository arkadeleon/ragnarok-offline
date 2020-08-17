//
//  DocumentItemsViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DocumentItemCell"

class DocumentItemsViewController: UIViewController {

    let documentItem: DocumentItem
    let documentItems: [DocumentItem]

    private var collectionView: UICollectionView!

    init(documentItem: DocumentItem) {
        self.documentItem = documentItem
        self.documentItems = (documentItem.children ?? []).sorted()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = documentItem.url.lastPathComponent

        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DocumentItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.reloadData()
    }
}

extension DocumentItemsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentItemCell
        cell.iconView.image = documentItems[indexPath.row].icon
        cell.nameLabel.text = documentItems[indexPath.row].url.lastPathComponent
        return cell
    }
}

extension DocumentItemsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentItem = documentItems[indexPath.row]
        switch documentItem {
        case .directory, .grf, .entryGroup:
            let documentItemsViewController = DocumentItemsViewController(documentItem: documentItem)
            navigationController?.pushViewController(documentItemsViewController, animated: true)
        case .text(let previewItem):
            let previewViewController = TextPreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .image(let previewItem):
            let previewViewController = ImagePreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .audio(let previewItem):
            let previewViewController = AudioPreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .sprite(let previewItem):
            let previewViewController = SpritePreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .action(let previewItem):
            let previewViewController = ActionPreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .model(let previewItem):
            let previewViewController = ModelPreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        case .world(let previewItem):
            let previewViewController = WorldPreviewViewController(previewItem: previewItem)
            navigationController?.pushViewController(previewViewController, animated: true)
        default:
            break
        }
    }
}
