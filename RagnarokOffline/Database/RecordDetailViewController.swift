//
//  RecordDetailViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/3/16.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import UIKit

class RecordDetailViewController: UIViewController {

    enum Item: Hashable {
        struct Entry: Hashable {
            var name: String
            var value: String
        }

        case header(String)
        case entry(Entry)
        case description(NSAttributedString)
        case record(AnyRecord)
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<String, Item>!
    private var record: AnyRecord

    init(record: AnyRecord) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
        title = record.recordName
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = true
            configuration.headerMode = .none
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)

        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = item

            cell.contentConfiguration = contentConfiguration
        }

        let entryCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item.Entry> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = item.name
            contentConfiguration.secondaryText = item.value

            cell.contentConfiguration = contentConfiguration
        }

        let descriptionCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSAttributedString> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.attributedText = item

            cell.contentConfiguration = contentConfiguration
        }

        let recordCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyRecord> { (cell, indexPath, item) in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = item.recordName

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = UICollectionViewDiffableDataSource<String, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .header(let header):
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: header)
            case .entry(let entry):
                return collectionView.dequeueConfiguredReusableCell(using: entryCellRegistration, for: indexPath, item: entry)
            case .description(let description):
                return collectionView.dequeueConfiguredReusableCell(using: descriptionCellRegistration, for: indexPath, item: description)
            case .record(let record):
                return collectionView.dequeueConfiguredReusableCell(using: recordCellRegistration, for: indexPath, item: record)
            }
        }

        var snapshot = NSDiffableDataSourceSnapshot<String, Item>()
        snapshot.appendSections([Strings.information])
        snapshot.appendItems([.header(Strings.information)], toSection: Strings.information)
        for field in record.recordFields {
            switch field.value {
            case .string(let value):
                let entry = Item.Entry(name: field.name, value: value)
                let item: Item = .entry(entry)
                snapshot.appendItems([item], toSection: Strings.information)
            case .attributedString(let value):
                var items: [Item] = [.header(field.name)]
                items += [.description(value)]
                snapshot.appendSections([field.name])
                snapshot.appendItems(items, toSection: field.name)
            case .references(let value):
                var items: [Item] = [.header(field.name)]
                items += value.map { .record($0) }
                snapshot.appendSections([field.name])
                snapshot.appendItems(items, toSection: field.name)
            }
        }
        dataSource.apply(snapshot)
    }
}

extension RecordDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }

        switch item {
        case .header, .entry, .description:
            return false
        case .record:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        guard case .record(let record) = item else {
            return
        }

        let recordDetailViewController = RecordDetailViewController(record: record)
        navigationController?.pushViewController(recordDetailViewController, animated: true)
    }
}
