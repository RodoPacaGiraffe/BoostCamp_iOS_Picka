//
//  RemovedPhotoStore.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class TemporaryPhotoStore: NSObject, NSCoding {
    weak var delegate: PhotoStoreDelegate?
    
    fileprivate(set) var photoAssets: [PHAsset] = []
    fileprivate(set) var photoAssetsIdentifier: [String] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()

        guard let loadedPhotoAssetsIdentifier = aDecoder.decodeObject(
            forKey: Constants.temporaryPhotoAssetsIdentifier) as? [String] else {
                return nil
        }
        
        photoAssetsIdentifier = loadedPhotoAssetsIdentifier
    }
    
    func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let result = PHAsset.fetchAssets(withLocalIdentifiers: photoAssetsIdentifier, options: fetchOptions)
        
        for index in 0 ..< result.count {
            photoAssets.append(result[index])
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(photoAssetsIdentifier, forKey: Constants.temporaryPhotoAssetsIdentifier)
    }
    
    func savePhotoAsset() {
        guard let path = Constants.archiveURL?.path else {
            return
        }
        
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
}

extension TemporaryPhotoStore {
    func insert(photoAssets: [PHAsset]) {
        photoAssets.forEach {
            self.photoAssets.append($0)
            photoAssetsIdentifier.append($0.localIdentifier)
        }
        
        temporaryPhotoDidInserted(insertedPhotoAssets: photoAssets)
        savePhotoAsset()
    }
    
    func remove(photoAssets: [PHAsset], isPerformDelegate: Bool = true) {
        photoAssets.forEach {
            guard let assetIndex = self.photoAssets.index(of: $0) else { return }
          
            self.photoAssets.remove(at: assetIndex)
            photoAssetsIdentifier.remove(at: assetIndex)
        }
        
        if isPerformDelegate {
            temporaryPhotoDidRemoved(removedPhotoAssets: photoAssets)
        }

        savePhotoAsset()
    }
    
    func removePhotoFromLibrary(with photoAssets: [PHAsset], completion: (() -> Void)?) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photoAssets as NSFastEnumeration)
        }) { [weak self] (isSuccess, error) in
            guard isSuccess else { return }
            
            self?.remove(photoAssets: photoAssets, isPerformDelegate: false)
            
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

extension TemporaryPhotoStore: PhotoStoreDelegate {
    func temporaryPhotoDidInserted(insertedPhotoAssets: [PHAsset]) {
        delegate?.temporaryPhotoDidInserted(insertedPhotoAssets: insertedPhotoAssets)
    }
    
    func temporaryPhotoDidRemoved(removedPhotoAssets: [PHAsset]) {
        delegate?.temporaryPhotoDidRemoved(removedPhotoAssets: removedPhotoAssets)
    }
}