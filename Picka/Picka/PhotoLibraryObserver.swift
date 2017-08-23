//
//  PhotoLibraryObserver.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 13..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {    
    private var fetchResult: PHFetchResult<PHAsset>?
    static let shared: PhotoLibraryObserver = PhotoLibraryObserver()
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setObserving(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult,
            let changeDetail = changeInstance.changeDetails(for: fetchResult) else { return }
        
        let removedPhotoAssets = [Constants.removedPhotoAssets: changeDetail.removedObjects]
        
        NotificationCenter.default.post(name: Constants.removedAssetsFromPhotoLibrary,
                                        object: nil, userInfo: removedPhotoAssets)
    }
}
