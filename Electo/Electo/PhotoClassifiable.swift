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
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> ([String:[[PHAsset]]], [String])
}

extension PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> ([String:[[PHAsset]]], [String]) {
        guard var firstPhotoAssetDate = photoAssets.first?.creationDate else { return ([:], []) }
        
        var classifiedPhotoAssets: [String:[[PHAsset]]] = [:]
        var tempPhotoAssets: [PHAsset] = []
        var creationDates: [String] = []
      
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return ([:], []) }
              let dateString = creationDate.toDateString()
            if !firstPhotoAssetDate.containedWithinBoundary(for: creationDate) { // guard
                if tempPhotoAssets.count > 1 && (classifiedPhotoAssets[dateString] == nil) {
                    classifiedPhotoAssets[dateString] = []
                    creationDates.append(dateString)
                }
                guard tempPhotoAssets.count > 1 else {
                    firstPhotoAssetDate = creationDate
                    tempPhotoAssets = []
                    tempPhotoAssets.append(photoAsset)
                    
                    continue
                }
                
                classifiedPhotoAssets[dateString]?.append(tempPhotoAssets)
                firstPhotoAssetDate = creationDate
                tempPhotoAssets = []
            }
            
            tempPhotoAssets.append(photoAsset)
        }
        
        return (classifiedPhotoAssets, creationDates)
    }
}
