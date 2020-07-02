//
//  DocumentWrappersViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DocumentWrapperCell"

class DocumentWrappersViewController: UIViewController {

    let documentWrapper: DocumentWrapper
    let documentWrappers: [DocumentWrapper]

    private var collectionView: UICollectionView!

    init(documentWrapper: DocumentWrapper) {
        self.documentWrapper = documentWrapper
        self.documentWrappers = (documentWrapper.documentWrappers ?? []).sorted()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = documentWrapper.name

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
        collectionView.register(DocumentWrapperCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.reloadData()
    }
}

extension DocumentWrappersViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentWrappers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentWrapperCell
        cell.iconView.image = documentWrappers[indexPath.row].icon
        cell.nameLabel.text = documentWrappers[indexPath.row].name
        return cell
    }
}

extension DocumentWrappersViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentWrapper = documentWrappers[indexPath.row]
        switch documentWrapper {
        case .directory, .archive, .directoryInArchive:
            let documentWrappersViewController = DocumentWrappersViewController(documentWrapper: documentWrapper)
            navigationController?.pushViewController(documentWrappersViewController, animated: true)
        case .textDocument(let document):
            let documentViewController = TextDocumentViewController(document: document)
            navigationController?.pushViewController(documentViewController, animated: true)
        case .imageDocument(let document):
            let documentViewController = ImageDocumentViewController(document: document)
            navigationController?.pushViewController(documentViewController, animated: true)
        case .rsmDocument(let document):
            let documentViewController = RSMDocumentViewController(document: document)
            navigationController?.pushViewController(documentViewController, animated: true)
        case .gndDocument(let document):
            let documentViewController = GNDDocumentViewController(document: document)
            navigationController?.pushViewController(documentViewController, animated: true)
        case .sprite(let document):
            let previewViewController = SpritePreviewViewController(document: document)
            navigationController?.pushViewController(previewViewController, animated: true)
        default:
            break
        }
    }
}
