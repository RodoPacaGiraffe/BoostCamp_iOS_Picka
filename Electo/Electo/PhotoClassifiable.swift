//
//  ClassifiedPhotoAssetFactory.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

protocol PhotoClassifiable: class {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [String:[[PHAsset]]]
}

extension PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [String:[[PHAsset]]] {
        guard var firstPhotoAssetDate = photoAssets.first?.creationDate else { return [:] }
        
        var classifiedPhotoAssets: [String:[[PHAsset]]] = [:]
        var tempPhotoAssets: [PHAsset] = []
        var dateString: String = ""
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return [:] }
            
            if !firstPhotoAssetDate.containedWithinBoundary(for: creationDate) { // guard
               
                guard tempPhotoAssets.count != 1 else {
                    firstPhotoAssetDate = creationDate
                    tempPhotoAssets = []
                    tempPhotoAssets.append(photoAsset)
                    
                    
                    continue
                }
                
                classifiedPhotoAssets[dateString]?.append(tempPhotoAssets)
                firstPhotoAssetDate = creationDate
                tempPhotoAssets = []
            }
            dateString = creationDate.toDateString()
            if classifiedPhotoAssets[dateString] == nil {
                classifiedPhotoAssets[dateString] = []
            }
            tempPhotoAssets.append(photoAsset)
        }
        return classifiedPhotoAssets
    }
}
