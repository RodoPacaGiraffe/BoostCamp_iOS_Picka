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
    var photoMetaData: [PhotoMetaData] = []
    let locationConverter = LocationConverter()
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
            photoMetaData.append(PhotoMetaData(creationDate: fetchResult[index].creationDate,
                                               location: fetchResult[index].location))
            guard let location = fetchResult[index].location else { continue }
            locationConverter.locationConverter(location: location)
        }
    }
    
    private func classifyPhotoAssetsByTime() {
        var firstPhotoAssetDate = (photoAssets.first?.creationDate)!
//        var classifiedPhotoAssets: [[PHAsset]] = []
        var tempPhotoAssets: [PHAsset] = []
        
        // TODO: Refactoring 필요, 한번에 추가하는 것 고려
        for photoAsset in photoAssets {
            if !firstPhotoAssetDate.containedWithinBoundary(for: photoAsset.creationDate!) { // guard
                guard tempPhotoAssets.count != 1 else {
                    firstPhotoAssetDate = photoAsset.creationDate!
                    tempPhotoAssets = []
                    tempPhotoAssets.append(photoAsset)
                    continue
                }
                
                classifiedPhotoAssets.append(tempPhotoAssets)
                firstPhotoAssetDate = photoAsset.creationDate!
                tempPhotoAssets = []
            }
            
            tempPhotoAssets.append(photoAsset)
        }
        
        print(classifiedPhotoAssets)
    }
}








