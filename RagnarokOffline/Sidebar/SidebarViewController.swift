//
//  SidebarViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/1.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, SidebarItem>!
    private var viewControllers: [SidebarItem: UINavigationController] = [:]

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = Strings.ragnarokOffline
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = sectionIndex == 0 ? .none : .firstItemInSection
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)

        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            cell.contentConfiguration = contentConfiguration
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.image = item.image
            contentConfiguration.text = item.title
            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Int, SidebarItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .database:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, SidebarItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.client, .server])
        snapshot.appendSections([1])
        snapshot.appendItems([.database, .weapons, .armors, .cards, .items, .monsters])
        dataSource.apply(snapshot)

        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        collectionView(collectionView, didSelectItemAt: indexPath)
    }
}

extension SidebarViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }

        switch item {
        case .database:
            return false
        default:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        var viewController = viewControllers[item]

        if viewController == nil {
            let rootViewController: UIViewController
            switch item {
            case .client:
                rootViewController = ClientViewController()
            case .server:
                rootViewController = UIViewController()
            case .database:
                fatalError("Database cannot be selected")
            case .weapons:
                rootViewController = RecordListViewController.weapons()
            case .armors:
                rootViewController = RecordListViewController.armors()
            case .cards:
                rootViewController = RecordListViewController.cards()
            case .items:
                rootViewController = RecordListViewController.items()
            case .monsters:
                rootViewController = RecordListViewController.monsters()
            }
            let navigationController = UINavigationController(rootViewController: rootViewController)
            viewController = navigationController
            viewControllers[item] = navigationController
        }

        if viewController != nil {
            splitViewController?.setViewController(viewController, for: .secondary)
        }
    }
}
