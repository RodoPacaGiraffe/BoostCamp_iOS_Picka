//
//  UIBarButtonItem.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    static func getUIBarbuttonItemincludedBadge(With temporaryPhotoAssetsCount: Int) -> UIBarButtonItem {
        let label = UILabel(frame: CGRect(x: 12, y: -8, width: 15, height: 15))
        
        label.text = "\(temporaryPhotoAssetsCount)"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.backgroundColor = .red
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.layer.masksToBounds = true
        
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
        
        guard let labelIndex = index, let label = button.subviews[labelIndex]
            as? UILabel else { return }
        
        guard temporaryPhotoAssetsCount != 0 else {
            label.isHidden = true
            self.isEnabled = false
            return
        }
        
        self.isEnabled = true
        label.isHidden = false

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
        
        if Locale.preferredLanguages.first == "ar" {
            label.text = temporaryPhotoAssetsCount.toArabic()
        } else {
            label.text = "\(temporaryPhotoAssetsCount)"
        }
    }
}
