//
//  RemovedPhotoViewController.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class TemporaryPhotoViewController: UIViewController {
    fileprivate enum SelectMode: String {
        case on = "Cancel"
        case off = "Choose"
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chooseButton: UIBarButtonItem!
    @IBOutlet weak var buttonForEditStackView: UIStackView!
    @IBOutlet weak var buttonForNormalStackView: UIStackView!
    
    var photoDataSource: PhotoDataSource?
    var tempThumbnailImages: [UIImage] = []
    var selectedIndexPaths: [IndexPath] = []
    
    fileprivate var selectMode: SelectMode = .off {
        didSet {
            toggleHiddenState(forViews: [buttonForEditStackView, buttonForNormalStackView])
            chooseButton.title = selectMode.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.allowsMultipleSelection = true
        
        setCellSize()
        
        NotificationCenter.default.addObserver(self, selector: #selector (reloadData),
                                               name: Constants.requiredReload, object: nil)
    }
    
    private func setCellSize() {
        let width = (collectionView.bounds.width / 4) - flowLayout.minimumLineSpacing * 2
        
        flowLayout.itemSize.width = width
        flowLayout.itemSize.height = width
    }
    
    private func toggleHiddenState(forViews views: [UIView]) {
        views.forEach {
            $0.isHidden = !$0.isHidden
        }
    }
    
    private func selectedPhotoAssets() -> [PHAsset] {
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return [] }
        guard let temporaryPhotoStore = self.photoDataSource?.temporaryPhotoStore else { return [] }
        
        var selectedPhotoAssets: [PHAsset] = []
        
        selectedItems.forEach {
            let selectedPhotoAsset = temporaryPhotoStore.photoAssets[$0.row]
            selectedPhotoAssets.append(selectedPhotoAsset)
        }
        
        return selectedPhotoAssets
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func initSelection() {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        collectionView.reloadItems(at: selectedItems)
    }
    
    @IBAction func toggleSelectMode(_ sender: UIBarButtonItem) {
        if selectMode == .off {
            selectMode = .on
        } else {
            selectMode = .off
            
            initSelection()
        }
    }
    
    @IBAction func recoverAll(_ sender: UIButton) {
        recoverAlertController(title: "Recover All Photos", message: "Recover All Photos") { (action) in
            guard let temporaryPhotoStore = self.photoDataSource?.temporaryPhotoStore else { return }
            let allRemovedPhotoAssets = temporaryPhotoStore.photoAssets
            temporaryPhotoStore.remove(photoAssets: allRemovedPhotoAssets)
            
            self.collectionView.reloadData()
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    @IBAction func recoverSelected(_ sender: UIButton) {
        recoverAlertController(title: "Recover Selected Photos", message: "Recover Selected Photos") { (action) in
            guard let temporaryPhotoStore = self.photoDataSource?.temporaryPhotoStore else { return }
            temporaryPhotoStore.remove(photoAssets: self.selectedPhotoAssets())
            
            self.collectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        temporaryPhotoStore.removePhotoFromLibrary(with: temporaryPhotoStore.photoAssets) {
            [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @IBAction func deleteSelected(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        temporaryPhotoStore.removePhotoFromLibrary(with: selectedPhotoAssets()) {
            [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func recoverAlertController(title: String, message: String, completion: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: "Recover", message: "", preferredStyle: .actionSheet)
        let recoverAction = UIAlertAction(title: title, style: .default, handler: completion)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(recoverAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TemporaryPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell else { return }
        
        switch selectMode {
        case .on:
            photoCell.select()
        case .off:
            guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
            guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "detailViewController") as? DetailPhotoViewController else { return }
            
            //TODO: 이미지 전체 넘겨주기
            detailViewController.selectedSectionAssets = temporaryPhotoStore.photoAssets
            detailViewController.identifier = "fromTemporaryViewController"
            
            guard let selectedThumbnailImage = photoCell.thumbnailImageView.image else { return }
            detailViewController.thumbnailImages.append(selectedThumbnailImage)
            detailViewController.pressedIndexPath = indexPath
            
            detailViewController.navigationItem.title = temporaryPhotoStore.photoAssets[indexPath.item]
                .creationDate?.toDateString()
            show(detailViewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        print("여기?")
        photoCell.deSelect()
    }
}
