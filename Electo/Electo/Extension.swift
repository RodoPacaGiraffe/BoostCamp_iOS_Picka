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
    @discardableResult func fetchImage(size: CGSize, contentMode: PHImageContentMode,
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
    func getDifference(from date: Date) -> Difference {
        let endTimeInterval = self.timeIntervalSince(date)
        
        let day1 = Calendar.current.component(.day, from: self)
        
        let day2 = Calendar.current.component(.day, from: date)
        
        if (abs(endTimeInterval) > Constants.timeIntervalBoundary) && (day1 == day2) {
            return .intervalBoundary
        } else if day1 != day2 {
            return .day
        } else {
            return .none
        }
    }

    func toDateString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()

        guard let languageCode = Locale.current.languageCode else { return "" }
        switch languageCode {
        case "ko":
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        case "zh", "ja":
            dateFormatter.dateFormat = "yyyy年 MM月 dd日 EEEE"
        case "ar":
            dateFormatter.dateFormat = "yyyy MM dd EEEE"
        default:
            dateFormatter.dateFormat = "E, d MMM yyyy"
        }
        
        return dateFormatter.string(from: self)
    }
}

extension CLLocation {
    func reverseGeocode(completion: @escaping (_ locationString: String) -> Void) {
        let geoCoder = CLGeocoder()
        var locationString: String = .init()
    
        geoCoder.reverseGeocodeLocation(self, completionHandler: { placemarks, error in
            guard let addressDictionary = placemarks?[0].addressDictionary else { return }
            guard let country = addressDictionary[LocationKey.country.rawValue] as? String else { return }
            guard let city = addressDictionary[LocationKey.city.rawValue] as? String else { return }
            
            locationString = "\(country) \(city)"
            
            completion(locationString)
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

extension UIBarButtonItem {
    static func getUIBarbuttonItemincludedBadge(With temporaryPhotoAssetsCount: Int) -> UIBarButtonItem {
        let label = UILabel(frame: CGRect(x: 12, y: -8, width: 15, height: 15))
        
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.layer.masksToBounds = true
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "\(temporaryPhotoAssetsCount)"
     
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
        button.addSubview(label)
        
        return UIBarButtonItem(customView: button)
    }
    
    func addButtonTarget(target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        guard let button = self.customView as? UIButton else { return }
        
        button.addTarget(target, action: action, for: controlEvents)
    }
    
    func updateBadge(With temporaryPhotoAssetsCount: Int) {
        guard let button = self.customView as? UIButton else { return }
        
        let index = button.subviews.index {
            return $0 is UILabel
        }
        
        guard let labelIndex = index, let label = button.subviews[labelIndex] as? UILabel else { return }
        
        if let text = label.text, let previousCount = Int(text),
            previousCount < temporaryPhotoAssetsCount {
            UIView.animate(withDuration: 0.2,
               animations: {
                button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
               completion: { _ in
                button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
        
        label.text = "\(temporaryPhotoAssetsCount)"
        
        guard temporaryPhotoAssetsCount != 0 else {
            self.isEnabled = false
            return
        }
        
        self.isEnabled = true
    }
}

extension UIView {
    func makeRoundBorder(degree: CGFloat) {
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.height / degree
        layer.masksToBounds = true
    }
}

extension String {
    func getAttributedString() -> NSMutableAttributedString {
        var titleAtributedString = NSMutableAttributedString()
        
        titleAtributedString = NSMutableAttributedString(string: self, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)])
        
        return titleAtributedString
    }
}
