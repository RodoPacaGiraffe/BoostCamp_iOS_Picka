//
//  RemovedPhotoStore.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class RemovedPhotoStore: NSObject, NSCoding {
    weak var delegate: PhotoAssetRemovable?
    
    fileprivate(set) var removedPhotoAssets: [PHAsset] = []
    fileprivate(set) var removedPhotoAssetsIdentifier: [String] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()

        guard let loadedPhotoAssetsIdentifier = aDecoder.decodeObject(
            forKey: Constants.removedPhotoAssetsIdentifier) as? [String] else {
                return nil
        }
        
        removedPhotoAssetsIdentifier = loadedPhotoAssetsIdentifier
        fetchPhotoAsset()
    }
    
    private func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let result = PHAsset.fetchAssets(withLocalIdentifiers: removedPhotoAssetsIdentifier, options: fetchOptions)
        
        for index in 0 ..< result.count {
            removedPhotoAssets.append(result[index])
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(removedPhotoAssetsIdentifier, forKey: Constants.removedPhotoAssetsIdentifier)
    }
    
    func saveRemovedPhotoAsset() {
        guard let path = Constants.archiveURL?.path else {
            return
        }
        
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
}

extension RemovedPhotoStore: PhotoAssetRemovable {
    func addPhotoAssets(toDelete photoAssets: [PHAsset]) {
        photoAssets.forEach {
            removedPhotoAssets.append($0)
            removedPhotoAssetsIdentifier.append($0.localIdentifier)
            remove(photoAsset: $0)
        }
        
        saveRemovedPhotoAsset()
    }
    
    func removePhotoAssets(toRestore photoAssets: [PHAsset]) {
        photoAssets.forEach {
            guard let assetIndex = removedPhotoAssets.index(of: $0) else { return }
            
            removedPhotoAssets.remove(at: assetIndex)
            removedPhotoAssetsIdentifier.remove(at: assetIndex)
            restore(photoAsset: $0)
        }
    
        saveRemovedPhotoAsset()
    }
    
    func removefromPhotoLibrary(with photoAssets: [PHAsset]) {
        photoAssets.forEach {
            guard let assetIndex = removedPhotoAssets.index(of: $0) else { return }
            
            removedPhotoAssets.remove(at: assetIndex)
            removedPhotoAssetsIdentifier.remove(at: assetIndex)
            restore(photoAsset: $0)
        }
        
        saveRemovedPhotoAsset()
    }
    
    func remove(photoAsset: PHAsset) {
        delegate?.remove(photoAsset: photoAsset)
    }
    
    func restore(photoAsset: PHAsset) {
        delegate?.restore(photoAsset: photoAsset)
    }
}
