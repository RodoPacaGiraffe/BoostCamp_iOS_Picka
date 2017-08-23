//
//  UIView.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 22..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

extension UIView {
    func makeRoundBorder(degree: CGFloat) {
        self.layoutIfNeeded()
        layer.cornerRadius = self.frame.height / degree
        layer.masksToBounds = true
    }
    
    func fadeWithAlpha(of view: UIView, duration: Double, alpha: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = alpha
        })
    }
}
