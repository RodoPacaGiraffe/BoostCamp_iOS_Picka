//
//  RemovedPhotoStore.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

fileprivate struct Constants {
    static let temporaryPhotoAssetsIdentifier: String = "temporaryPhotoAssetsIdentifier"
}

class TemporaryPhotoStore: NSObject, NSCoding {
    weak var delegate: PhotoStoreDelegate?
    
    fileprivate(set) var photoAssets: [PHAsset] = []
    fileprivate(set) var photoAssetsIdentifier: [String] = []
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: NotificationName.removedAssetsFromPhotoLibrary, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: NotificationName.removedAssetsFromPhotoLibrary, object: nil)
        
        guard let loadedPhotoAssetsIdentifier = aDecoder.decodeObject(
            forKey: Constants.temporaryPhotoAssetsIdentifier) as? [String] else {
            return nil
        }
        
        photoAssetsIdentifier = loadedPhotoAssetsIdentifier
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        guard let path = ArchiveConstants.archiveURL?.path else { return }
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    @objc func applyRemovedAssets(_ notification: Notification) {
        guard let removedPhotoAssets = notification.userInfo?[NotificationUserInfoKey.removedPhotoAssets]
            as? [PHAsset] else { return }
        
        removedPhotoAssets.forEach {
            guard let index = photoAssets.index(of: $0) else { return }
            
            photoAssets.remove(at: index)
        }
        
        NotificationCenter.default.post(name: NotificationName.requiredReload, object: nil)
    }
}

extension TemporaryPhotoStore {
    func insert(photoAssets: [PHAsset]) {
        photoAssets.forEach {
            self.photoAssets.append($0)
            photoAssetsIdentifier.append($0.localIdentifier)
        }
        
        delegate?.temporaryPhotoDidInserted(insertedPhotoAssets: photoAssets)
        savePhotoAsset()
        
        NotificationCenter.default.post(name: NotificationName.requiredUpdatingBadge, object: nil)
    }
    
    func remove(photoAssets: [PHAsset], isPerformDelegate: Bool = true) {
        photoAssets.forEach {
            guard let assetIndex = self.photoAssets.index(of: $0) else { return }
            self.photoAssets.remove(at: assetIndex)
            photoAssetsIdentifier.remove(at: assetIndex)
        }
        
        if isPerformDelegate {
            delegate?.temporaryPhotoDidRemoved(removedPhotoAssets: photoAssets)
        }

        savePhotoAsset()
        
        NotificationCenter.default.post(name: NotificationName.requiredUpdatingBadge, object: nil)
    }
    
    func removePhotoFromLibrary(with photoAssets: [PHAsset], completion: (() -> Void)?) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(photoAssets as NSFastEnumeration)
        }) { [weak self] (isSuccess, _) in
            guard isSuccess else { return }
            
            self?.remove(photoAssets: photoAssets, isPerformDelegate: false)
            
            DispatchQueue.main.async {
                if let completion = completion {
                    completion()
                }
                
                NotificationCenter.default.post(name: NotificationName.requiredUpdatingBadge, object: nil)
            }
        }
    }
}

