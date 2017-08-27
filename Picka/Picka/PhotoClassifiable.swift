//
//  ClassifiedPhotoAssetFactory.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

fileprivate struct Constants {
    static let minimumPhotoCount: Int = 2
}

protocol PhotoClassifiable: class {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [ClassifiedGroupsByDate]
}

extension PhotoClassifiable {
    func classifyByTimeInterval(photoAssets: [PHAsset]) -> [ClassifiedGroupsByDate] {
        guard var referencePhotoAssetDate = photoAssets.first?.creationDate else { return [] }
        
        var classifiedGroupsByDateArray: [ClassifiedGroupsByDate] = []
        var tempClassifiedPHAssetGroup: ClassifiedPHAssetGroup = ClassifiedPHAssetGroup()
        var tempClassifiedPHAssetGroups: [ClassifiedPHAssetGroup] = []
        
        for photoAsset in photoAssets {
            guard let creationDate = photoAsset.creationDate else { return [] }
            let creationDateCompareResult = referencePhotoAssetDate.compare(with: creationDate)
        
            switch creationDateCompareResult {
            case .containsIntervalboundaryAndDate:
                tempClassifiedPHAssetGroup.appendPhotoAsset(photoAsset)
                continue
            case .differentIntervalBoundary:
                if tempClassifiedPHAssetGroup.photoAssets.count >= Constants.minimumPhotoCount {
                    tempClassifiedPHAssetGroups.append(tempClassifiedPHAssetGroup)
                    tempClassifiedPHAssetGroup = ClassifiedPHAssetGroup()
                }
            case .differentDate:
                if tempClassifiedPHAssetGroup.photoAssets.count >= Constants.minimumPhotoCount {
                    tempClassifiedPHAssetGroups.append(tempClassifiedPHAssetGroup)
                    tempClassifiedPHAssetGroup = ClassifiedPHAssetGroup()
                }
                
                guard !tempClassifiedPHAssetGroups.isEmpty else { break }

                let classifiedGroupsByDate = ClassifiedGroupsByDate(date: referencePhotoAssetDate,
                                                                  classifiedPHAssetGroups: tempClassifiedPHAssetGroups)
                
                classifiedGroupsByDateArray.append(classifiedGroupsByDate)
                tempClassifiedPHAssetGroups.removeAll()
            }
            
            referencePhotoAssetDate = creationDate
            tempClassifiedPHAssetGroup.removeAllPhotoAssets()
            tempClassifiedPHAssetGroup.appendPhotoAsset(photoAsset)
        }
        
        return classifiedGroupsByDateArray
    }
}
