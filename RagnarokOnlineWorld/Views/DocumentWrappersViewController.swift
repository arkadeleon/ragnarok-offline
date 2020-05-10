//
//  DocumentWrappersViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DocumentWrapperCell"

class DocumentWrappersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    let documentWrapper: DocumentWrapper
    let documentWrappers: [DocumentWrapper]

    private var collectionView: UICollectionView!

    init(documentWrapper: DocumentWrapper) {
        self.documentWrapper = documentWrapper
        self.documentWrappers = Array((documentWrapper.documentWrappers ?? [:]).values).sorted()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = documentWrapper.name

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DocumentWrapperCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentWrappers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DocumentWrapperCell
        cell.iconView.image = documentWrappers[indexPath.row].icon
        cell.nameLabel.text = documentWrappers[indexPath.row].name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let documentWrapper = documentWrappers[indexPath.row]
        switch documentWrapper {
        case .textDocument(let document):
            let textDocumentViewController = TextDocumentViewController(document: document)
            navigationController?.pushViewController(textDocumentViewController, animated: true)
        default:
            break
        }

        if let _ = documentWrapper.documentWrappers {
            let documentWrappersViewController = DocumentWrappersViewController(documentWrapper: documentWrapper)
            navigationController?.pushViewController(documentWrappersViewController, animated: true)
        }
    }
}
