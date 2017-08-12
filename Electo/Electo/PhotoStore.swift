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
    fileprivate(set) var classifiedPhotoAssets: [[PHAsset]] = []
    
    func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        for index in 0 ..< fetchResult.count {
            photoAssets.append(fetchResult[index])
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
    }
    
    func applyRemovedPhotoAssets(loadedPhotoAssets: [PHAsset]?) {
        guard let loadedPhotoAssets = loadedPhotoAssets else { return }
        
        loadedPhotoAssets.forEach {
            guard let removedAssetIndex = photoAssets.index(of: $0) else { return }
            photoAssets.remove(at: removedAssetIndex)
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
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


