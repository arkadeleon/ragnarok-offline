//
//  RecordListViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/2.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import UIKit

class RecordListViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Record>!
    private var snapshot: NSDiffableDataSourceSnapshot<Int, Record>

    init(snapshot: NSDiffableDataSourceSnapshot<Int, Record>) {
        self.snapshot = snapshot
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionViewLayout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = true
            configuration.headerMode = .none
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Record> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = item.name

            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Record>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.apply(snapshot)
    }
}

extension RecordListViewController: UICollectionViewDelegate {
}
