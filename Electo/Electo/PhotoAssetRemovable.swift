//
//  PhotoAssetRemovable.swift
//  Electo
//
//  Created by 임성훈 on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

protocol PhotoAssetRemovable: class {
    func remove(photoAsset: PHAsset)
}
