//
//  GalleryScreen.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Артем Свиридов on 09.10.2022.
//

import UIKit

final class GalleryScreen: UIViewController {

    // MARK: - Private

    // MARK: Variables

    private var deleteImagesPath: Set<String> = []
    private var imagesModel = [ImageModel]()
    private let manager = FileManager.default

    // MARK: UI

    private lazy var addButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        return button
    }()

    private lazy var trashButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAction))
        button.isEnabled = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            GalleryCollectionViewCell.self,
            forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    // MARK: - Override functions

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        showImages()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        collectionView.allowsMultipleSelection = editing
        navigationItem.rightBarButtonItem = editing ? trashButtonItem : addButtonItem
        let indexPaths = collectionView.indexPathsForVisibleItems
        indexPaths.forEach {
            let cell = collectionView.cellForItem(at: $0) as? GalleryCollectionViewCell
            cell?.isInEditingMode = editing
        }

        if !editing {
            deleteImagesPath.removeAll()
        }
    }

}

// MARK: - Private functions

private extension GalleryScreen {

    func showImages() {
        do {
            let contents = try manager.contentsOfDirectory(at: .documentsDirectory, includingPropertiesForKeys: nil)
            for content in contents {
                if let image = UIImage(contentsOfFile: content.relativePath) {
                    imagesModel.append(ImageModel(path: content.relativePath, image: image))
                }
            }
            collectionView.reloadData()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }

    func setupView() {
        view.backgroundColor = .white
        navigationItem.title = Constants.title
        navigationItem.rightBarButtonItem = addButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
    }

    @objc
    func addAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc
    func deleteAction() {
        deleteImagesPath.forEach { imagePath in
            imagesModel.removeAll { $0.path == imagePath }
            do {
                try manager.removeItem(atPath: imagePath)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        collectionView.reloadData()
        deleteImagesPath.removeAll()
        trashButtonItem.isEnabled = false
    }

    func setupLayout() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

// MARK: - UIImagePickerControllerDelegate

extension GalleryScreen: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        let imageName = UUID().uuidString

        guard let imagePath = getDocumentsDirectory()?.appending(component: imageName),
              let jpegData = image.jpegData(compressionQuality: 0.8)
        else { return }

        manager.createFile(atPath: imagePath.relativePath, contents: jpegData)
        imagesModel.append(ImageModel(path: imagePath.relativePath, image: image))
        collectionView.reloadData()
        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL? {
        do {
            let documentUrl = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            return documentUrl
        } catch let error {
            debugPrint(error.localizedDescription)
            return nil
        }
    }

}

// MARK: - UINavigationControllerDelegate

extension GalleryScreen: UINavigationControllerDelegate {}

// MARK: - UICollectionViewDataSource

extension GalleryScreen: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GalleryCollectionViewCell.identifier,
            for: indexPath
        ) as? GalleryCollectionViewCell,
              let image = imagesModel[indexPath.item].image
        else { return UICollectionViewCell() }

        cell.setupCell(with: image)
        cell.isInEditingMode = isEditing
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagesModel.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        trashButtonItem.isEnabled = isEditing

        if let path = imagesModel[indexPath.item].path, isEditing {
            deleteImagesPath.insert(path)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            trashButtonItem.isEnabled = false
        }

        if let path = imagesModel[indexPath.item].path, isEditing {
            deleteImagesPath.remove(path)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryScreen: UICollectionViewDelegateFlowLayout {

    private var sideInset: CGFloat { return 8 }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 4 * sideInset) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sideInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        sideInset
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: sideInset, left: sideInset, bottom: sideInset, right: sideInset)
    }

}

// MARK: - Constants {

private extension GalleryScreen {

    enum Constants {
        static let title = "Gallery"
    }

}

