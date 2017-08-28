//
//  ClassifiedPHAssetGroup.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 19..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class ClassifiedPHAssetGroup {
    private(set) var photoAssets: [PHAsset] = []
    private(set) var location: String = ""
    
    func appendPhotoAsset(_ photoAsset: PHAsset) {
        photoAssets.append(photoAsset)
    }
    
    func removeAllPhotoAssets() {
        photoAssets.removeAll()
    }
    
    func setLocation(with locationText: String) {
        location = locationText
    }
}
