//
//  PhotoDataSource.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class PhotoDataSource: NSObject, NSKeyedUnarchiverDelegate {
    var photoStore: PhotoStore = PhotoStore()
    
    var temporaryPhotoStore: TemporaryPhotoStore = TemporaryPhotoStore() {
        didSet {
            temporaryPhotoStore.delegate = photoStore
        }
    }
    
    override init() {
        temporaryPhotoStore.delegate = photoStore
        
        super.init()
    }
}

extension PhotoDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return photoStore.classifiedPhotoAssets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoStore.classifiedPhotoAssets[section].photoAssetsArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return photoStore.classifiedPhotoAssets[section].date.toDateString()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        let classifiedPhotoAsset = photoStore.classifiedPhotoAssets[indexPath.section].photoAssetsArray[indexPath.row]
        
        var fetchedImages: [UIImage] = .init()
        
        if !cell.requestIDs.isEmpty {
            cell.requestIDs.forEach {
                cachingImageManager.cancelImageRequest($0)
            }
            cell.requestIDs.removeAll()
        }
        
        classifiedPhotoAsset.photoAssets.forEach {
            cell.requestIDs.append($0.fetchImage(size: Constants.fetchImageSize,
                          contentMode: .aspectFill, options: nil) { photoImage in
                            guard let photoImage = photoImage else { return }
                            fetchedImages.append(photoImage)
                            
                            if classifiedPhotoAsset.photoAssets.count == fetchedImages.count {
                            cell.cellImages = fetchedImages
                            cell.requestIDs.removeAll()
                            }
            })
        }
        
        let localizedString = NSLocalizedString("%d Photos", comment: "")
        cell.numberOfPhotosLabel.text = String(format: localizedString,
                                               classifiedPhotoAsset.photoAssets.count)

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let classifiedPhotoAssets = photoStore.classifiedPhotoAssets[indexPath.section]
        let assets = classifiedPhotoAssets.photoAssetsArray[indexPath.row]
        
        temporaryPhotoStore.insert(photoAssets: assets.photoAssets)
        
        if classifiedPhotoAssets.photoAssetsArray.count == 1 {
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        NotificationCenter.default.post(name: Constants.requiredUpdatingBadge, object: nil)
    }
}

// TemporaryPhotoViewController - DataSource
extension PhotoDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return temporaryPhotoStore.photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
            for: indexPath) as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        let temporaryPhotoAsset = temporaryPhotoStore.photoAssets[indexPath.item]

        if let selectedItems = collectionView.indexPathsForSelectedItems,
            selectedItems.contains(indexPath) {
            cell.select()
        } else {
            cell.deSelect()
        }
        
        temporaryPhotoAsset.fetchImage(size: Constants.fetchImageSize,
                                     contentMode: .aspectFill, options: nil) { removedPhotoImage in
                                        guard let removedPhotoImage = removedPhotoImage else { return }
                                                
                                        cell.addRemovedImage(removedPhotoImage: removedPhotoImage)
        }
    
        return cell
    }
}

