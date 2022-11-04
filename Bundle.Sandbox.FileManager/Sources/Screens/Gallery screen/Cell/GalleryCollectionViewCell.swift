//
//  GalleryCollectionViewCell.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Артем Свиридов on 09.10.2022.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {

    // MARK: - Private

    // MARK: UI

    private let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleToFill
        return image
    }()

    private let checkmarkImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        return image
    }()

    // MARK: - Override

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    // MARK: Variables

    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                checkmarkImage.image = isSelected ? Constants.checkmarkImage : Constants.emptyImage
            }
        }
    }

    // MARK: - Public

    // MARK: Variables

    var isInEditingMode = false {
        didSet {
            checkmarkImage.isHidden = !isInEditingMode
            if !isInEditingMode {
                checkmarkImage.image = Constants.emptyImage
            }
        }
    }

    // MARK: Functions

    func setupCell(with image: UIImage) {
        self.image.image = image
    }

}

// MARK: - Private functions

private extension GalleryCollectionViewCell {

    func layout() {
        let size = contentView.bounds.width / 4

        contentView.addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(checkmarkImage)
        NSLayoutConstraint.activate([
            checkmarkImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            checkmarkImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            checkmarkImage.widthAnchor.constraint(equalToConstant: size),
            checkmarkImage.heightAnchor.constraint(equalToConstant: size)
        ])
    }

}

// MARK: - Constants

private extension GalleryCollectionViewCell {

    enum Constants {
        static let emptyImage = UIImage()
        static let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
    }

}
