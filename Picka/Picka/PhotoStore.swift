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
    fileprivate(set) var classifiedGroupsByDate: [ClassifiedGroupsByDate] = [] {
        didSet {
            if classifiedGroupsByDate.isEmpty {
                NotificationCenter.default.post(name: NotificationName.appearStatusDisplayView, object: nil)
            } else if oldValue.isEmpty {
                NotificationCenter.default.post(name: NotificationName.disappearStatusDisplayView, object: nil)
            }
        }
    }
  
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector (applyRemovedAssets(_:)),
                                               name: NotificationName.removedAssetsFromPhotoLibrary, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

        PhotoLibraryObserver.shared.setObserving(for: photoAssets)
        classifiedGroupsByDate = classifyByTimeInterval(photoAssets: photoAssets)
    }
    
    @discardableResult func applyUnarchivedPhoto(assets: [PHAsset]?) -> [PHAsset]? {
        guard let unarchivedPhotoAssets = assets else { return nil }
        
        var removedAssetsFromPhotoLibrary: [PHAsset]?
    
        unarchivedPhotoAssets.forEach {
            guard let unarchivedPhotoAssetsIndex = photoAssets.index(of: $0) else {
                removedAssetsFromPhotoLibrary?.append($0)
                return
            }
            photoAssets.remove(at: unarchivedPhotoAssetsIndex)
        }
        
        classifiedGroupsByDate = classifyByTimeInterval(photoAssets: photoAssets)
        
        return removedAssetsFromPhotoLibrary
    }
    
    @objc private func applyRemovedAssets(_ notification: Notification) {
        guard let removedPhotoAssets = notification.userInfo?[NotificationUserInfoKey.removedPhotoAssets]
            as? [PHAsset] else { return }
        
        removedPhotoAssets.forEach {
            guard let index = photoAssets.index(of: $0) else { return }
            photoAssets.remove(at: index)
        }

        classifiedGroupsByDate = classifyByTimeInterval(photoAssets: photoAssets)
        
        NotificationCenter.default.post(name: NotificationName.requiredReload, object: nil)
    }
}

extension PhotoStore: PhotoStoreDelegate {
    func temporaryPhotoDidInserted(insertedPhotoAssets: [PHAsset]) {
        insertedPhotoAssets.forEach {
            guard let index = photoAssets.index(of: $0) else { return }
            photoAssets.remove(at: index)
        }
        
        classifiedGroupsByDate = classifyByTimeInterval(photoAssets: photoAssets)
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
        
        classifiedGroupsByDate = classifyByTimeInterval(photoAssets: photoAssets)
    }
}


