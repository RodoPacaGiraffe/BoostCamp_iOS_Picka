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
    case level1 = 60
    case level2 = 180
    case level3 = 300
}

struct Clustering {
    static let interval1: Range<Float> = 60..<120
    static let interval2: Range<Float> = 120..<240
    static let interval3: Range<Float> = 240..<300
}

enum Situation {
    case noPhoto
    case noAuthorization
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
    static let requiredUpdatingBadge = Notification.Name("requiredUpdatingBadge")
    static let loadingTime: TimeInterval = 1.5

    static let archiveURL: URL? = {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentDirectory = documentDirectories.first else { return nil }
        
        return documentDirectory.appendingPathComponent(Constants.archiveFileName)
    }()
    
    static let numberOfTapsRequired: Int = 2
    static var dataAllowed: Bool = true
    static let fetchImageSize = CGSize(width: 150, height: 150)
    static let deleteConfirmationView: String = "UITableViewCellDeleteConfirmationView"
  
}
