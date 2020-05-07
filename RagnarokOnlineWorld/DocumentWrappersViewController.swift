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
        self.documentWrappers = documentWrapper.documentWrappers ?? []
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
        guard let _ = documentWrappers[indexPath.row].documentWrappers else {
            return
        }
        let documentWrappersViewController = DocumentWrappersViewController(documentWrapper: documentWrappers[indexPath.row])
        navigationController?.pushViewController(documentWrappersViewController, animated: true)
    }
}
