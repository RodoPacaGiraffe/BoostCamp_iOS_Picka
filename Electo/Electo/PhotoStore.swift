//
//  PhotoStore.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class PhotoStore: PhotoClassifiable {
    private(set) var photoAssets: [PHAsset] = []
    private(set) var classifiedPhotoAssets: [[PHAsset]] = []
    
    init() {
        fetchPhotoAsset()
        
        if let classifiedPhotoAssets = classifyByTimeInterval(photoAssets: photoAssets) {
            self.classifiedPhotoAssets = classifiedPhotoAssets
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("reload"), object: nil)
    }
    
    private func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        for index in 0 ..< fetchResult.count {
            photoAssets.append(fetchResult[index])
//            photoAssets[index].location?.reverseGeocode()
        }
    }
}






