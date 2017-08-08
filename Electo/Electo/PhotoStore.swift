//
//  PhotoStore.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class PhotoStore {
    private(set) var photoAssets: [PHAsset] = []
    private(set) var classifiedPhotoAssets: [[PHAsset]] = []
    
    init() {
        fetchPhotoAsset()
        classifyPhotoAssetsByTime()
    }
    
    private func fetchPhotoAsset() {
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: Order.creationDate.rawValue,
                                                         ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        for index in 0 ..< fetchResult.count {
            photoAssets.append(fetchResult[index])
            photoAssets[index].location?.reverseGeocode()
        }
    }
    
    private func classifyPhotoAssetsByTime() {
        guard var firstPhotoAssetDate = photoAssets.first?.creationDate else { return }
//        var classifiedPhotoAssets: [[PHAsset]] = []
        var tempPhotoAssets: [PHAsset] = []
        
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return }
            
            if !firstPhotoAssetDate.containedWithinBoundary(for: creationDate) { // guard
                guard tempPhotoAssets.count != 1 else {
                    firstPhotoAssetDate = creationDate
                    tempPhotoAssets = []
                    tempPhotoAssets.append(photoAsset)
                    continue
                }
                
                classifiedPhotoAssets.append(tempPhotoAssets)
                firstPhotoAssetDate = creationDate
                tempPhotoAssets = []
            }
            
            tempPhotoAssets.append(photoAsset)
        }
        
        print(classifiedPhotoAssets)
    }
}








