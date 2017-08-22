//
//  PhotoStore.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class PhotoStore: PhotoClassifiable {
    fileprivate(set) var photoAssets: [PHAsset] = []
    var classifiedPhotoAssets: [ClassifiedPhotoAssets] = []
  
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: Constants.removedAssetsFromPhotoLibrary, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.removedAssetsFromPhotoLibrary, object: nil)
    }
    
    func fetchPhotoAsset() {
        photoAssets.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        for index in 0 ..< fetchResult.count {
            photoAssets.append(fetchResult[index])
        }

        PhotoLibraryObserver.shared.setObserving(fetchResult: fetchResult)
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
    }
    
    @discardableResult func applyUnarchivedPhoto(assets: [PHAsset]?) -> [PHAsset]?{
        guard let unarchivedPhotoAssets = assets else { return nil }
        
        var removedAssetsFromPhotoLibrary: [PHAsset]? = nil
    
        unarchivedPhotoAssets.forEach {
            guard let unarchivedPhotoAssetsIndex = photoAssets.index(of: $0) else {
                removedAssetsFromPhotoLibrary?.append($0)
                return
            }
            
            photoAssets.remove(at: unarchivedPhotoAssetsIndex)
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
        
        return removedAssetsFromPhotoLibrary
    }
    
    @objc func applyRemovedAssets(_ notification: Notification) {
        guard let removedPhotoAssets = notification.userInfo?[Constants.removedPhotoAssets]
            as? [PHAsset] else { return }
        
        removedPhotoAssets.forEach {
            guard let index = photoAssets.index(of: $0) else {
                print("This photoAsset is not founded from PhotoStore")
                return
            }

            photoAssets.remove(at: index)
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
        NotificationCenter.default.post(name: Constants.requiredReload, object: nil)
    }
}

extension PhotoStore: PhotoStoreDelegate {
    func temporaryPhotoDidInserted(insertedPhotoAssets: [PHAsset]) {
        insertedPhotoAssets.forEach {
            guard let index = photoAssets.index(of: $0) else {
                print("This photoAsset is not founded")
                return
            }
            
            photoAssets.remove(at: index)
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
    }

    func temporaryPhotoDidRemoved(removedPhotoAssets: [PHAsset]) {
        removedPhotoAssets.forEach {
            photoAssets.append($0)
        }
        
        photoAssets.sort { (before, after) in
            guard let beforeCreationDate = before.creationDate,
                let afterCreationDate = after.creationDate else { return false }
            
            return beforeCreationDate > afterCreationDate
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
    }
}


