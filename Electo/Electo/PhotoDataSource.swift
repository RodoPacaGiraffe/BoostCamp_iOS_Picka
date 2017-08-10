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
    let photoStore: PhotoStore
    let removeStore: RemovedPhotoStore
    
    override init() {
        guard let path = Constants.archiveURL?.path,
            let archivedRemoveStore = NSKeyedUnarchiver.unarchiveObject(withFile: path)
                as? RemovedPhotoStore else {
            removeStore = RemovedPhotoStore()
            photoStore = PhotoStore(loadedPhotoAssets: nil)
                    
            super.init()
            return
        }
        
        removeStore = archivedRemoveStore
        photoStore = PhotoStore(loadedPhotoAssets: removeStore.removedPhotoAssets)
        removeStore.delegate = photoStore
        
        super.init()
    }
}

extension PhotoDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return photoStore.classifiedPhotoAssets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.maximumSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        let photoAssets = photoStore.classifiedPhotoAssets[indexPath.section]
        var fetchedImages: [UIImage] = .init()
        
        let options: PHImageRequestOptions = .init()
        options.isSynchronous = true
        photoAssets.forEach {
            $0.fetchImage(size: CGSize(width: 50, height: 50),
                contentMode: .aspectFit, options: options) { photoImage in
                guard let photoImage = photoImage else { return }
                fetchedImages.append(photoImage)
                    
                if photoAssets.count == fetchedImages.count {
                    cell.cellImages = fetchedImages
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let assets = photoStore.classifiedPhotoAssets[indexPath.section]
        
        removeStore.addPhotoAssets(toDelete: assets)
        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}

extension PhotoDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return removeStore.removedPhotoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
            for: indexPath) as? RemovedPhotoCell ?? RemovedPhotoCell()
        let removedPhotoAsset = removeStore.removedPhotoAssets[indexPath.item]
        
        removedPhotoAsset.fetchImage(size: CGSize(width: 50, height: 50),
            contentMode: .aspectFit, options: nil) { removedPhotoImage in
            guard let removedPhotoImage = removedPhotoImage else { return }
                        
            cell.addRemovedImage(removedPhotoImage: removedPhotoImage)
        }
    
        return cell
    }
}

