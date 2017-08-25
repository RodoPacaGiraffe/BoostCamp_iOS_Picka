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

enum Status {
    case emptyPhotoToOrganize
    case noAuthorization
}
struct Language {
    static let korean: String = "ko"
    static let chinese: String = "zh"
    static let japanese: String = "ja"
    static let english: String = "en"
    static let arabic: String = "ar"
}

struct Clustering {
    static let interval1: Range<Float> = 60..<120
    static let interval2: Range<Float> = 120..<240
    static let interval3: Range<Float> = 240..<300
}

struct NotificationName {
    static let removedAssetsFromPhotoLibrary = Notification.Name("removedAssetsFromPhotoLibrary")
    static let requiredReload = Notification.Name("requiredReload")
    static let requiredUpdatingBadge = Notification.Name("requiredUpdatingBadge")
    static let appearStatusDisplayView = Notification.Name("appearStatusDisplayView")
    static let disappearStatusDisplayView = Notification.Name("disappearStatusDisplayView")
}

struct NotificationUserInfoKey {
    static let removedPhotoAssets = "removedPhotoAssets"
}

struct ArchiveConstants {
    static let archiveFileName: String = "temporaryPhotoStore.archive"
    static let archiveURL: URL? = {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = documentDirectories.first else { return nil }
        
        return documentDirectory.appendingPathComponent(ArchiveConstants.archiveFileName)
    }()
}

struct SettingConstants {
    static var timeIntervalBoundary: TimeInterval = 90.0
    static var networkDataAllowed: Bool = true
    static let fetchImageSize = CGSize(width: 150, height: 150)
    static let loadingTime: TimeInterval = 1.5
}
