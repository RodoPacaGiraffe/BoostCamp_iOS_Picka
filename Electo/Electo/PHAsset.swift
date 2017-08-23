//
//  Extension.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    @discardableResult func fetchImage(size: CGSize, contentMode: PHImageContentMode,
                                       options: PHImageRequestOptions?,
                                       resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        var imageRequestID: PHImageRequestID = PHImageRequestID()
        
        imageRequestID = cachingImageManager.requestImage(for: self, targetSize: size,
            contentMode: contentMode, options: options) { (image, _) in
                resultHandler(image)
        }
        
        return imageRequestID
    }
    
    func fetchFullSizeImage(options: PHImageRequestOptions?, resultHandler: @escaping (Data?) -> Void) {
        cachingImageManager.requestImageData(for: self, options: options) {
            (data, _, _, _) in
            resultHandler(data)
        }
    }
}
