//
//  Extension.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 7..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos
import MapKit

extension PHAsset {
    func fetchImage(size: CGSize, contentMode: PHImageContentMode,
                    options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        var imageRequestID: PHImageRequestID = .init()
        
        imageRequestID = cachingImageManager.requestImage(for: self, targetSize: size,
            contentMode: contentMode, options: options) { image, _ in
            resultHandler(image)
        }
        
        return imageRequestID
    }
    
    func fetchFullSizeImage(options: PHImageRequestOptions?, resultHandler: @escaping (Data?) -> Void) {
        cachingImageManager.requestImageData(for: self, options: options) { (data, string
            , orientation, _) in
            resultHandler(data)
        }
    }
}

extension Date {
    func containedWithinBoundary(for date: Date) -> Bool {
        let endTimeInterval = self.timeIntervalSince(date)
        
        return abs(endTimeInterval) <= Constants.timeIntervalBoundary
    }
    
    func toDateString() -> String {
        let dateForamtter: DateFormatter = DateFormatter()
        
        dateForamtter.dateFormat = "yyyy/MM/DD"
        
        return dateForamtter.string(from: self)
    }
}

extension CLLocation {
    func reverseGeocode() {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(self, completionHandler: { placemarks, error in
            guard let addressDictionary = placemarks?[0].addressDictionary else { return }
            guard let city = addressDictionary[LocationKey.city] as? String else { return }
            guard let country = addressDictionary[LocationKey.country] as? String else { return }
            print(city)
            print(country)
        })
    }
}

extension UIImage {
    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension PHImageRequestOptions {
    func setImageRequestOptions(networkAccessAllowed: Bool, synchronous: Bool,
                                deliveryMode: PHImageRequestOptionsDeliveryMode,
                                progressHandler:  PHAssetImageProgressHandler?) {
        self.isNetworkAccessAllowed = networkAccessAllowed
        self.isSynchronous = synchronous
        self.deliveryMode = deliveryMode
        self.progressHandler = progressHandler
    }
}
