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
      
        return photoStore.creationDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionCount = photoStore.classifiedPhotoAssets[photoStore.creationDate[section]]?.count else {
            return 0
        }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard photoStore.classifiedPhotoAssets[photoStore.creationDate[section]]?.count != nil else {
            return ""
        }
        return "\(photoStore.creationDate[section])"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? ClassifiedPhotoCell ?? ClassifiedPhotoCell()
        
        let creationDate = photoStore.creationDate[indexPath.section]
        let photoAssets = photoStore.classifiedPhotoAssets[creationDate]?[indexPath.row]
        var fetchedImages: [UIImage] = .init()
     
        
        let options: PHImageRequestOptions = .init()
        options.isSynchronous = true
        photoAssets?.forEach {
            $0.fetchImage(size: CGSize(width: 50, height: 50),
                          contentMode: .aspectFit, options: options) { photoImage in
                            guard let photoImage = photoImage else { return }
                            fetchedImages.append(photoImage)
                            
                            if photoAssets?.count == fetchedImages.count {
                            cell.cellImages = fetchedImages
                            }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let creationDate = photoStore.creationDate[indexPath.section]
        guard let assets = photoStore.classifiedPhotoAssets[creationDate]?[indexPath.row] else { return }
        
        temporaryPhotoStore.insert(photoAssets: assets)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
        
}

extension PhotoDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return temporaryPhotoStore.photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier,
            for: indexPath) as? TemporaryPhotoCell ?? TemporaryPhotoCell()
        let removedPhotoAsset = temporaryPhotoStore.photoAssets[indexPath.item]
        
        removedPhotoAsset.fetchImage(size: CGSize(width: 90, height: 90),
            contentMode: .aspectFit, options: nil) { removedPhotoImage in
            guard let removedPhotoImage = removedPhotoImage else { return }
                        
            cell.addRemovedImage(removedPhotoImage: removedPhotoImage)
        }
    
        return cell
    }
}

