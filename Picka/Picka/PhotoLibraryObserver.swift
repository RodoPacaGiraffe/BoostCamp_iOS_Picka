//
//  PhotoLibraryObserver.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 13..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {    
    private var photoAssets: [PHAsset] = []
    static let shared: PhotoLibraryObserver = PhotoLibraryObserver()
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setObserving(for photoAssets: [PHAsset]) {
        self.photoAssets = photoAssets
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        var temporaryRemovedPhotoAssets: [PHAsset] = []
        
        for (index, photoAsset) in photoAssets.enumerated().reversed() {
            guard let changeDetail = changeInstance.changeDetails(for: photoAsset) else { continue }
            guard changeDetail.objectWasDeleted else { continue }

            temporaryRemovedPhotoAssets.append(photoAsset)
            photoAssets.remove(at: index)
        }
        
        guard !temporaryRemovedPhotoAssets.isEmpty else { return }
        
        let removedPhotoAssets = [NotificationUserInfoKey.removedPhotoAssets: temporaryRemovedPhotoAssets]

        NotificationCenter.default.post(name: NotificationName.removedAssetsFromPhotoLibrary,
                                        object: nil, userInfo: removedPhotoAssets)
    }
}
