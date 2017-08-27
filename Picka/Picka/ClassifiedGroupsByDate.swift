//
//  ClassifiedGroupsByDate.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 15..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation

class ClassifiedGroupsByDate {
    private(set) var date: Date = Date()
    private(set) var classifiedPHAssetGroups: [ClassifiedPHAssetGroup] = []
    
    init(date: Date, classifiedPHAssetGroups: [ClassifiedPHAssetGroup]) {
        self.date = date
        self.classifiedPHAssetGroups = classifiedPHAssetGroups
    }
}
