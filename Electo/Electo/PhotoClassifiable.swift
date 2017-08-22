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
        var tempPhotoAssets: ClassifiedGroup = ClassifiedGroup()
        var tempPhotoAssetsArray: [ClassifiedGroup] = []
        
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return [] }
            let difference = referencePhotoAssetDate.getDifference(from: creationDate)
        
            switch difference {
            case .none:
                tempPhotoAssets.photoAssets.append(photoAsset)
                continue
            case .intervalBoundary:
                if tempPhotoAssets.photoAssets.count >= Constants.minimumPhotoCount {
                    tempPhotoAssetsArray.append(tempPhotoAssets)
                    tempPhotoAssets = ClassifiedGroup()
                }
            case .day:
                if tempPhotoAssets.photoAssets.count >= Constants.minimumPhotoCount {
                    tempPhotoAssetsArray.append(tempPhotoAssets)
                    tempPhotoAssets = ClassifiedGroup()
                }
                
                guard !tempPhotoAssetsArray.isEmpty else { break }

                let classifiedPhotoAssets = ClassifiedPhotoAssets(date: referencePhotoAssetDate,
                                                                  photoAssetsArray: tempPhotoAssetsArray)
                
                classifiedPhotoAssetsArray.append(classifiedPhotoAssets)
                tempPhotoAssetsArray.removeAll()
            }
            
            referencePhotoAssetDate = creationDate
            tempPhotoAssets.photoAssets.removeAll()
            tempPhotoAssets.photoAssets.append(photoAsset)
        }
        
        return classifiedPhotoAssetsArray
    }
}
