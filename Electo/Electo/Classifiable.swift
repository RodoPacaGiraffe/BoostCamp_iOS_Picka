//
//  ClassifiedPhotoAssetFactory.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

protocol PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [[PHAsset]]
}

extension PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [[PHAsset]] {
        guard var firstPhotoAssetDate = photoAssets.first?.creationDate else { return [] }
        
        var classifiedPhotoAssets: [[PHAsset]] = []
        var tempPhotoAssets: [PHAsset] = []
        
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return [] }
            
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
        
        return classifiedPhotoAssets
    }
}
