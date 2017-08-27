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

enum AssetCreationDateCompareResult {
    case containsIntervalboundaryAndDate
    case differentDate
    case differentIntervalBoundary
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
    static var timeIntervalBoundary: TimeInterval = 180
    static let defaultTimeIntervalBoundary: TimeInterval = 180
    static let defaultNetworkDataAllowed: Bool = true
    static var networkDataAllowed: Bool = true
    static let fetchImageSize = CGSize(width: 150, height: 150)
    static let loadingTime: TimeInterval = 1.5
}

struct LocalizationKey {
    static let useCellularData: String = "Use Cellular Data"
    static let numberOfPhotos: String = "%d Photos"
    static let noAuthorization: String = "No Authorization"
    static let noPhotosToOrganize: String = "No photos to organize"
    static let goSettings: String = "Go Settings"
    static let cancel: String = "Cancel"
    static let ok: String = "OK"
    static let recoverAllPhotos: String = "Recover All Photos"
    static let recoverSelectedPhotos: String = "Recover Selected Photos"
    static let choose: String = "Choose";
    static let numberOfPhotosRecovered = "%d photos recovered."
    static let numberOfPhotosDeleted = "%d photos deleted."
}

struct UserDefaultsKey {
    static let networkDataAllowed: String = "networkDataAllowed"
    static let timeIntervalBoundary: String = "timeIntervalBoundary"
}

struct StoryBoardIdentifier {
    static let detailViewController: String = "detailViewController"
}

struct SegueIdentifier {
    static let modalTemporaryPhotoVC: String = "ModalTemporaryPhotoVC"
    static let modalSettingVC: String = "ModalSettingVC"
}

struct PreviousVCIdentifier {
    static let fromClassifiedPhotoVC: String = "fromClassifiedPhotoVC"
    static let fromTemporaryPhotoVC: String = "fromTemporaryPhotoVC"
}
