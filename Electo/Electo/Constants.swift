//
//  Constants.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation

enum Order: String {
    case creationDate
}

enum LocationKey: String {
    case name = "Name"
    case city = "City"
    case country = "Country"
    case zip = "ZIP"
}

struct Constants {
    static let cellIdentifier: String = "ClassifiedPhotoCell"
    static let timeIntervalBoundary: TimeInterval = 60.0
    static let maximumImageView: Int = 4
    static let stackViewSpacing: Int = 3
    static let temporaryPhotoAssetsIdentifier: String = "temporaryPhotoAssetsIdentifier"
    static let archiveFileName: String = "temporaryPhotoStore.archive"
    static let maximumSection: Int = 1
    static let loadingTime: TimeInterval = 1
    static let archiveURL: URL? = {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentDirectory = documentDirectories.first else { return nil }
        
        return documentDirectory.appendingPathComponent(Constants.archiveFileName)
    }()
}
