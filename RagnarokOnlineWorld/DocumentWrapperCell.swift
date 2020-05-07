//
//  DocumentWrapperCell.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class DocumentWrapperCell: UICollectionViewCell {
    let iconView: UIImageView
    let nameLabel: UILabel

    override init(frame: CGRect) {
        iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label

        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        super.init(frame: frame)

        contentView.addSubview(iconView)
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true

        contentView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
