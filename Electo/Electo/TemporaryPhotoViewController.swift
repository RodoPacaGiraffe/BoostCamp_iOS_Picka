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
    var tempThumbnailImages: [UIImage] = .init()
    var isSelected: Bool = true
    
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
    
    private func resetSelectedItem(indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard let photoCell = collectionView.cellForItem(at: $0)
                as? TemporaryPhotoCell else { return }
            
            collectionView.deselectItem(at: $0, animated: true)
            photoCell.deSelect()
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
    
    @IBAction func toggleSelectMode(_ sender: UIBarButtonItem) {
        switch selectMode {
        case .on:
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                resetSelectedItem(indexPaths: selectedItems)
            }
            selectMode = .off
        case .off:
            selectMode = .on
        }
    }
    
    @IBAction func recoverAll(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        let allRemovedPhotoAssets = temporaryPhotoStore.photoAssets
        temporaryPhotoStore.remove(photoAssets: allRemovedPhotoAssets)
        
        collectionView.reloadData()
    }
    
    @IBAction func recoverSelected(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        
        temporaryPhotoStore.remove(photoAssets: selectedPhotoAssets())
        resetSelectedItem(indexPaths: selectedItems)
        
        collectionView.reloadData()
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
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        
        temporaryPhotoStore.removePhotoFromLibrary(with: selectedPhotoAssets()) {
            [weak self] in
            self?.collectionView.reloadData()
        }
        resetSelectedItem(indexPaths: selectedItems)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func longPressSelectAction(_ sender: UILongPressGestureRecognizer) {
        if selectMode == .off {
            selectMode = .on
            guard let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: collectionView)) else { return }
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
            collectionView(collectionView, didSelectItemAt: indexPath)
            
        }
    }
    
    @IBAction func panGestureSelectAction(_ sender: UIPanGestureRecognizer) {

        guard let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: collectionView)) else { return }
        if selectMode == .on && isSelected {
            
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
            collectionView(collectionView, didSelectItemAt: indexPath)
            if sender.state == .ended {
                isSelected = false
            }
            
        } else {
            guard let indexPath = self.collectionView.indexPathForItem(at: sender.location(in: collectionView)) else { return }
            
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView(collectionView, didDeselectItemAt: indexPath)
            if sender.state == .ended {
                isSelected = true
            }
        }
    }
}


extension TemporaryPhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        
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
            show(detailViewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        
        photoCell.deSelect()
    }
}
