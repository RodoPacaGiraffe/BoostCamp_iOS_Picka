//
//  EmptyView.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 19..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    class func instanceFromNib() -> EmptyView {
        guard let emptyView = UINib(nibName: "EmptyView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? EmptyView else {
            return EmptyView()
        }
        
        return emptyView
    }
}
