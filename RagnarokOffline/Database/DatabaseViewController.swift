//
//  DatabaseViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import UIKit

class DatabaseViewController: UIViewController {

    enum Item: Hashable {
        case weapons
        case armors
        case cards
        case items
        case monsters

        var title: String {
            switch self {
            case .weapons:
                return R.string.weapons
            case .armors:
                return R.string.armors
            case .cards:
                return R.string.cards
            case .items:
                return R.string.items
            case .monsters:
                return R.string.monsters
            }
        }
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = R.string.database
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

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = item.title

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems([.weapons, .armors, .cards, .items, .monsters], toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension DatabaseViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let viewController: UIViewController

        switch item {
        case .weapons:
            viewController = RecordListViewController.weapons()
        case .armors:
            viewController = RecordListViewController.armors()
        case .cards:
            viewController = RecordListViewController.cards()
        case .items:
            viewController = RecordListViewController.items()
        case .monsters:
            viewController = RecordListViewController.monsters()
        }

        navigationController?.pushViewController(viewController, animated: true)
    }
}
