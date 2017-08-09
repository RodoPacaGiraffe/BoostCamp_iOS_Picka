//
//  RemovedPhotoStore.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class RemovedPhotoStore: PhotoAssetRemovable {
    weak var delegate: PhotoAssetRemovable?
    
    private(set) var removedPhotoAssets: [PHAsset] = []
    
    func addPhotoAsset(toDelete photoAsset: PHAsset) {
        removedPhotoAssets.append(photoAsset)
        remove(photoAsset: photoAsset)
    }
    
    func addPhotoAssets(toDelete photoAssets: [PHAsset]) {
        photoAssets.forEach {
            removedPhotoAssets.append($0)
            remove(photoAsset: $0)
        }
    }
    
    func removePhotoAsset(toRestore photoAsset: PHAsset) {
        guard let assetIndex = removedPhotoAssets.index(of: photoAsset) else { return }
        
        removedPhotoAssets.remove(at: assetIndex)
        restore(photoAsset: photoAsset)
    }
    
    func removePhotoAssets(toRestore photoAssets: [PHAsset]) {
        photoAssets.forEach {
            guard let assetIndex = removedPhotoAssets.index(of: $0) else { return }
            
            removedPhotoAssets.remove(at: assetIndex)
            restore(photoAsset: $0)
        }
    }
    
    func remove(photoAsset: PHAsset) {
        delegate?.remove(photoAsset: photoAsset)
    }
    
    func restore(photoAsset: PHAsset) {
        delegate?.restore(photoAsset: photoAsset)
    }
}
