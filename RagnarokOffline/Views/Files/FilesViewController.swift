//
//  FilesViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FilesViewController: UIViewController {
    let file: File
    private var files: [File] = []

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, File>!

    init(file: File) {
        self.file = file

        super.init(nibName: nil, bundle: nil)

        title = file.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        addActionCollectionView()
        addActivityIndicatorView()

        activityIndicatorView.startAnimating()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        Task {
            if navigationController?.viewControllers.count == 1 {
                let navigationItem = navigationController?.navigationBar.topItem
                navigationItem?.searchController = searchController
                navigationItem?.hidesSearchBarWhenScrolling = false
            }
        }

        Task {
            files = await loadFiles()
            await updateSnapshot(with: files, animatingDifferences: false)
            activityIndicatorView.stopAnimating()
        }
    }

    private func addActionCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 32
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.itemSize = CGSize(width: 80, height: 88)
        flowLayout.sectionInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag

        let cellRegistration = UICollectionView.CellRegistration<FileCollectionViewCell, File> { cell, indexPath, file in

        }

        diffableDataSource = UICollectionViewDiffableDataSource<Int, File>(collectionView: collectionView) { collectionView, indexPath, file in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: file)
            cell.configure(with: file)
            return cell
        }
        collectionView.dataSource = diffableDataSource

        view.addSubview(collectionView)
    }

    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicatorView)

        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    nonisolated private func loadFiles() async -> [File] {
        file.files().sorted()
    }

    nonisolated private func updateSnapshot(with files: [File], animatingDifferences: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, File>()

        snapshot.appendSections([0])
        snapshot.appendItems(files, toSection: 0)

        await diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func presentFileInfoViewController(file: File) {
        let fileInfoViewController = FileInfoViewController(file: file)
        let navigationController = UINavigationController(rootViewController: fileInfoViewController)
        present(navigationController, animated: true)
    }

    private func presentFilePreviewViewController(file: File) {
        let files = diffableDataSource.snapshot().itemIdentifiers.filter { file in
            guard let type = file.type else {
                return false
            }
            if type.conforms(to: .directory) || type.conforms(to: .archive) {
                return false
            } else {
                return true
            }
        }

        let pageViewController = FilePreviewPageViewController(file: file, files: files)
        let navigationController = UINavigationController(rootViewController: pageViewController)
        navigationController.modalTransitionStyle = .coverVertical
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension FilesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = diffableDataSource.itemIdentifier(for: indexPath), let type = file.type else {
            return
        }

        if type.conforms(to: .directory) || type.conforms(to: .archive) {
            let filesViewController = FilesViewController(file: file)
            navigationController?.pushViewController(filesViewController, animated: true)
        } else {
            presentFilePreviewViewController(file: file)
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPaths.isEmpty, case .directory = file, FilePasteboard.shared.hasFile {
            let pasteAction = UIAction(title: "Paste", image: UIImage(systemName: "doc.on.clipboard")) { _ in
                if let file = self.file.pasteFromPasteboard(FilePasteboard.shared) {
                    Task {
                        var files = self.diffableDataSource.snapshot().itemIdentifiers
                        files.append(file)
                        files.sort()
                        await self.updateSnapshot(with: files, animatingDifferences: true)
                    }
                }
            }
            let configuration = UIContextMenuConfiguration(actionProvider: { _ in
                UIMenu(children: [pasteAction])
            })
            return configuration
        }

        guard let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath),
              let file = diffableDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        var actions: [UIAction] = []

        if file.jsonRepresentable {
            let fileInfoAction = UIAction(title: "File Info", image: UIImage(systemName: "info.circle")) { _ in
                self.presentFileInfoViewController(file: file)
            }
            actions.append(fileInfoAction)
        }

        if let type = file.type, !type.conforms(to: .directory) && !type.conforms(to: .archive) {
            let previewAction = UIAction(title: "Preview", image: UIImage(systemName: "eye")) { _ in
                self.presentFilePreviewViewController(file: file)
            }
            actions.append(previewAction)
        }

        switch file {
        case .regularFile, .grf, .grfEntry:
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                FilePasteboard.shared.copy(file)
            }
            actions.append(copyAction)
        default:
            break
        }

        if let activityItem = file.activityItem {
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = cell
                activityViewController.popoverPresentationController?.sourceRect = cell.bounds
                self.present(activityViewController, animated: true)
            }
            actions.append(shareAction)
        }

        if case .regularFile(let url) = file {
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                do {
                    try FileManager.default.removeItem(at: url)
                    Task {
                        var files = self.diffableDataSource.snapshot().itemIdentifiers
                        files.removeAll(where: { $0 == file })
                        await self.updateSnapshot(with: files, animatingDifferences: true)
                    }
                } catch {
                }
            }
            actions.append(deleteAction)
        }

        let configuration = UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: actions)
        })
        return configuration
    }
}

extension FilesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let filteredFiles: [File]
        if let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased(), !searchText.isEmpty {
            filteredFiles = files.filter { file in
                file.name.lowercased().contains(searchText)
            }
        } else {
            filteredFiles = files
        }

        Task {
            await updateSnapshot(with: filteredFiles, animatingDifferences: true)
        }
    }
}

extension FilesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
