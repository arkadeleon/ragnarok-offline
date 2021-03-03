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
        title = "Ragnarok Offline"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let collectionViewLayout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = .none
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)

        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = item.title

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
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

        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        snapshot.append([.client, .server])
        snapshot.append([.database])
        snapshot.expand([.database])
        snapshot.append([.weapons, .armors, .cards, .items, .monsters, .skills], to: .database)
        dataSource.apply(snapshot, to: 0, animatingDifferences: false)

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
                rootViewController = UIViewController()
            case .weapons:
                let snapshot = NSDiffableDataSourceSnapshot<Int, Record>.snapshotForWeapons()
                rootViewController = RecordListViewController(snapshot: snapshot)
            case .armors:
                rootViewController = UIViewController()
            case .cards:
                rootViewController = UIViewController()
            case .items:
                rootViewController = UIViewController()
            case .monsters:
                rootViewController = UIViewController()
            case .skills:
                rootViewController = UIViewController()
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
