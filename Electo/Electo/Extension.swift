//
//  Extension.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    func fetchImage(size: CGSize, contentMode: PHImageContentMode,
                    options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?) -> Void) {
        let cachingImageManager = PHCachingImageManager()
            cachingImageManager.requestImage(for: self, targetSize: size,
                contentMode: contentMode, options: options) { image, _ in
                resultHandler(image)
        }
    }
}

extension Date {
    func containedWithinBoundary(for date: Date) -> Bool {
        let endTimeInterval = self.timeIntervalSince(date)
    
        guard abs(endTimeInterval) <= Constants.timeIntervalBoundary else {
            return false
        }
        
        return true
    }
}
