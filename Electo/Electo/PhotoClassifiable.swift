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
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [ClassifiedPhotoAssets]
}

extension PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [ClassifiedPhotoAssets] {
        guard var referencePhotoAssetDate = photoAssets.first?.creationDate else { return [] }
        var classifiedPhotoAssetsArray: [ClassifiedPhotoAssets] = []
        var tempPhotoAssets: [PHAsset] = []
        var tempPhotoAssetsArray: [[PHAsset]] = []
        
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return [] }
        
            let difference = referencePhotoAssetDate.getDifference(from: creationDate)
        
            switch difference {
            case .none:
                tempPhotoAssets.append(photoAsset)
                continue
            case .intervalBoundary:
                if tempPhotoAssets.count > Constants.minimumPhotoCount - 1 {
                    tempPhotoAssetsArray.append(tempPhotoAssets)
                }
            case .day:
                if tempPhotoAssets.count > Constants.minimumPhotoCount - 1 {
                    tempPhotoAssetsArray.append(tempPhotoAssets)
                }
                
                guard !tempPhotoAssetsArray.isEmpty else { break }
                
                let classifiedPhotoAssets = ClassifiedPhotoAssets(
                    date: referencePhotoAssetDate, photoAssetsArray: tempPhotoAssetsArray)
                
                classifiedPhotoAssetsArray.append(classifiedPhotoAssets)
                tempPhotoAssetsArray.removeAll()
            }
            
            referencePhotoAssetDate = creationDate
            tempPhotoAssets.removeAll()
            tempPhotoAssets.append(photoAsset)
        }

        return classifiedPhotoAssetsArray
    }
}
