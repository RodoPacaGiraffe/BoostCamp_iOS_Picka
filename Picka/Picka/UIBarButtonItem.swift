//
//  UIBarButtonItem.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    struct BadgeLabel {
        static let frame: CGRect = CGRect(x: 12, y: -8, width: 15, height: 15)
        static let font: UIFont = UIFont.systemFont(ofSize: 10)
    }
    
    struct BadgeButton {
        static let frame: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20)
    }
    
    struct BadgeAnimation {
        static let badgeTargetScale: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.2)
        static let badgeOriginalScale: CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        static let duration: TimeInterval = 0.2
    }
}

extension UIBarButtonItem {
    static func getUIBarbuttonItemincludedBadge(With temporaryPhotoAssetsCount: Int) -> UIBarButtonItem {
        let label = UILabel(frame: Constants.BadgeLabel.frame)
        
        label.text = "\(temporaryPhotoAssetsCount)"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Constants.BadgeLabel.font
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.backgroundColor = .red
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.layer.masksToBounds = true
        
        let button = UIButton(frame: Constants.BadgeButton.frame)
        
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
            UIView.animate(withDuration: Constants.BadgeAnimation.duration,
                animations: {
                    button.transform = Constants.BadgeAnimation.badgeTargetScale
            },
                completion: { _ in
                    button.transform = Constants.BadgeAnimation.badgeOriginalScale
            })
        }
        
        if Locale.preferredLanguages.first == Language.arabic {
            label.text = temporaryPhotoAssetsCount.toArabic()
        } else {
            label.text = "\(temporaryPhotoAssetsCount)"
        }
    }
}
