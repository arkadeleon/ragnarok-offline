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
    private var dataSource: UICollectionViewDiffableDataSource<Int, AnyRecord>!
    private var records: [AnyRecord]

    init(records: [AnyRecord]) {
        self.records = records
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

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyRecord> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = item.name

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = UICollectionViewDiffableDataSource<Int, AnyRecord>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, AnyRecord>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.records, toSection: 0)
        dataSource.apply(snapshot)
    }
}

extension RecordListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let recordDetailViewController = RecordDetailViewController(record: item)
        navigationController?.pushViewController(recordDetailViewController, animated: true)
    }
}
