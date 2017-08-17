//
//  ClassifiedPhotoAssets.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 15..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

struct ClassifiedPhotoAssets {
    let date: Date
    var photoAssetsArray: [ClassifiedGroup]
}

class ClassifiedGroup {
    var photoAssets: [PHAsset] = []
    var location: String = ""
    
    func getLocation(location: String) {
        self.location = location
    }
}
