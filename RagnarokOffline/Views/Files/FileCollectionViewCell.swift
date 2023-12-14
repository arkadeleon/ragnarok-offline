//
//  FileCollectionViewCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FileCollectionViewCell: UICollectionViewCell {
    var thumbnailView: UIImageView!
    var nameLabel: UILabel!

    private var thumbnailTask: Task<UIImage?, Error>?

    override init(frame: CGRect) {
        super.init(frame: frame)

        thumbnailView = UIImageView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.tintColor = .label
        contentView.addSubview(thumbnailView)

        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        thumbnailView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.numberOfLines = 2
        contentView.addSubview(nameLabel)

        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 8).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailTask?.cancel()
        thumbnailTask = nil
    }

    func configure(with file: File) {
        if let type = file.type, type.conforms(to: .directory) {
            thumbnailView.image = file.icon?.withRenderingMode(.alwaysOriginal)
        } else {
            thumbnailView.image = file.icon?.withRenderingMode(.alwaysTemplate)
        }

        thumbnailTask = FileThumbnailManager.shared.thumbnailTask(for: file)

        Task {
            if let thumbnail = try await thumbnailTask?.value {
                thumbnailView.image = thumbnail
            }
        }

        nameLabel.text = file.name
    }
}
