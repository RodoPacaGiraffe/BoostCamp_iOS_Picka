//
//  Constants.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

enum PhotoIndex: Int {
    case first = 0
    case second = 1
    case third = 2
    case fourth = 3
}
enum Order: String {
    case creationDate
}

enum LocationKey: String {
    case name = "Name"
    case city = "City"
    case country = "Country"
    case zip = "ZIP"
}

enum Difference {
    case none
    case day
    case intervalBoundary
}

enum GroupingInterval: Float {
    case level1 = 30
    case level2 = 60
    case level3 = 90
    case level4 = 120
    case level5 = 150
}

struct Clustering {
    static let interval1: Range<Float> = 30..<45
    static let interval2: Range<Float> = 45..<75
    static let interval3: Range<Float> = 75..<105
    static let interval4: Range<Float> = 105..<135
    static let interval5: Range<Float> = 135..<150
}

let cachingImageManager: PHCachingImageManager = PHCachingImageManager()

struct Constants {
    static let cellIdentifier: String = "ClassifiedPhotoCell"
    static var timeIntervalBoundary: TimeInterval = 90.0
    static let maximumImageView: Int = 4
    static let stackViewSpacing: Int = 3
    static let temporaryPhotoAssetsIdentifier: String = "temporaryPhotoAssetsIdentifier"
    static let archiveFileName: String = "temporaryPhotoStore.archive"
    static let maximumSection: Int = 1
    static let minimumPhotoCount: Int = 2
    static let removedPhotoAssets = "removedPhotoAssets"
    static let removedAssetsFromPhotoLibrary = Notification.Name("removedAssetsFromPhotoLibrary")
    static let requiredReload = Notification.Name("requiredReload")
    static let loadingTime: TimeInterval = 1.5

    static let archiveURL: URL? = {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentDirectory = documentDirectories.first else { return nil }
        
        return documentDirectory.appendingPathComponent(Constants.archiveFileName)
    }()
    
    static let numberOfTapsRequired: Int = 2
    static var dataAllowed: Bool = true
    static let fetchImageSize = CGSize(width: 90, height: 90)
}
