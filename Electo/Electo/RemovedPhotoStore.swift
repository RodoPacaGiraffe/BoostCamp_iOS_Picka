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
    
    private(set) var removedPhotoAssets: [PHAsset] = [] {
        didSet {
            if let appendedPhotoAsset = removedPhotoAssets.last {
                remove(photoAsset: appendedPhotoAsset)
                print(appendedPhotoAsset)
            }
        }
    }
    
    func addPhotoAsset(toDelete photoAsset: PHAsset) {
        removedPhotoAssets.append(photoAsset)
    }
    
    func addPhotoAssets(toDelete photoAssets: [PHAsset]) {
        photoAssets.forEach {
            removedPhotoAssets.append($0)
        }
    }
    
    func remove(photoAsset: PHAsset) {
        delegate?.remove(photoAsset: photoAsset)
    }
}
