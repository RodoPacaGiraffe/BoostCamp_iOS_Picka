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
    
    init() {
        fetchPhotoAsset()
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
        
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    private func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        for index in 0 ..< fetchResult.count {
            
            photoAssets.append(fetchResult[index])
            photoAssets[index].location?.reverseGeocode()
        }
    }
}

extension PhotoStore: PhotoAssetRemovable {
    func remove(photoAsset: PHAsset) {
        guard let photoAsset = photoAssets.index(of: photoAsset) else {
            print("This photoAsset is not founded")
            return
        }
        
        photoAssets.remove(at: photoAsset)
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
    }
    
    func restore(photoAsset: PHAsset) {
        photoAssets.append(photoAsset)
        photoAssets.sort { (before, after) in
            guard let beforeCreationDate = before.creationDate,
                let afterCreationDate = after.creationDate else { return false }
            
            return beforeCreationDate > afterCreationDate
        }
        
        classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets)
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
}




