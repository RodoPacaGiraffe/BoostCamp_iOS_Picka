//
//  ClassifiedPhotoAssets.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 15..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

class ClassifiedPhotoAssets {
    var date: Date = Date()
    var photoAssetsArray: [ClassifiedGroup] = []
    
    init(date: Date, photoAssetsArray: [ClassifiedGroup]) {
        self.date = date
        self.photoAssetsArray = photoAssetsArray
    }
}
