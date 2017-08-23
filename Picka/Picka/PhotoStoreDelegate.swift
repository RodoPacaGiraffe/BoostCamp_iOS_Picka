//
//  PhotoAssetRemovable.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

protocol PhotoStoreDelegate: class {
    func temporaryPhotoDidInserted(insertedPhotoAssets: [PHAsset])
    func temporaryPhotoDidRemoved(removedPhotoAssets: [PHAsset])
}
