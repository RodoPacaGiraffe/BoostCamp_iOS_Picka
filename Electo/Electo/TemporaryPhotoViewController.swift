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
    
    @IBAction func recoverAll(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        
        let allRemovedPhotoAssets = temporaryPhotoStore.photoAssets
        temporaryPhotoStore.remove(photoAssets: allRemovedPhotoAssets)
        
        collectionView.reloadData()
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        
    }
    
    @IBAction func recoverSelected(_ sender: UIButton) {
        guard let temporaryPhotoStore = photoDataSource?.temporaryPhotoStore else { return }
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        
        temporaryPhotoStore.remove(photoAssets: selectedPhotoAssets())
        resetSelectedItem(indexPaths: selectedItems)
        
        collectionView.reloadData()
    }
    
    @IBAction func toggleSelectMode(_ sender: UIBarButtonItem) {
        if selectMode == .off {
            selectMode = .on
        } else {
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                resetSelectedItem(indexPaths: selectedItems)
            }
            
            selectMode = .off
        }
    }
    
    @IBAction func deleteSelected(_ sender: UIButton) {
        switch selectMode {
        case .off:
            PHPhotoLibrary.shared().performChanges({
                guard let asset = self.photoDataSource?.temporaryPhotoStore.photoAssets else { return }
                
                PHAssetChangeRequest.deleteAssets(asset as NSFastEnumeration)
            }) { (success, error) in
                print("success")
            }
        case .on:
            PHPhotoLibrary.shared().performChanges({ 
                PHAssetChangeRequest.deleteAssets(self.selectedPhotoAssets() as NSFastEnumeration)
            }) { (success, error) in
                print("success")
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
            guard let detailViewController = storyboard?.instantiateViewController(withIdentifier:  "temporaryDetailPhotoViewController") as? TemporaryDetailPhotoViewController else { return }
            detailViewController.selectedPhotos = temporaryPhotoStore.photoAssets
            show(detailViewController, sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let photoCell = collectionView.cellForItem(at: indexPath)
            as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        
        photoCell.deSelect()
    }
}
