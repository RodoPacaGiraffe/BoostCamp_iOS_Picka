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
    static let stackViewSpacing: Int = 1
}
