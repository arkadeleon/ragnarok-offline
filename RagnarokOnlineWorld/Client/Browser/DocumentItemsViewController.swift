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
    var childDocumentItems: [DocumentItem] = []

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    init(documentItem: DocumentItem) {
        self.documentItem = documentItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = documentItem.title

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

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        DispatchQueue.global().async {
            self.childDocumentItems = (self.documentItem.children ?? []).sorted()
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.collectionView.reloadData()
            }
        }

    }
}

extension DocumentItemsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childDocumentItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentItemCell
        cell.iconView.image = childDocumentItems[indexPath.item].icon
        cell.nameLabel.text = childDocumentItems[indexPath.item].title
        return cell
    }
}

extension DocumentItemsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentItem = childDocumentItems[indexPath.item]
        switch documentItem {
        case .directory, .grf, .entryGroup:
            let documentItemsViewController = DocumentItemsViewController(documentItem: documentItem)
            navigationController?.pushViewController(documentItemsViewController, animated: true)
        case .previewItem(let previewItem):
            switch previewItem.fileType {
            case .txt, .xml, .ini, .lua, .lub:
                let previewViewController = TextPreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .bmp, .jpg, .tga, .pal:
                let previewViewController = ImagePreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .mp3, .wav:
                let previewViewController = AudioPreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .spr:
                let previewViewController = SpritePreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .act:
                let previewViewController = ActionPreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .rsm:
                let previewViewController = ModelPreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .rsw:
                let previewViewController = WorldPreviewViewController(previewItem: previewItem)
                navigationController?.pushViewController(previewViewController, animated: true)
            case .xxx:
                break
            }
        }
    }
}
