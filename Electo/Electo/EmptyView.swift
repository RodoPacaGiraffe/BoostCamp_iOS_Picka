//
//  EmptyView.swift
//  Electo
//
//  Created by Alpaca on 2017. 8. 19..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    @IBOutlet private var statementLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    class func instanceFromNib(situation: Situation, frame: CGRect) -> EmptyView {
        guard let emptyView = UINib(nibName: "EmptyView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? EmptyView else {
            return EmptyView()
        }
        emptyView.frame = frame
        emptyView.setEmptyView(accordingTo: situation)
        
        return emptyView
    }
    
    private func setEmptyView(accordingTo situation: Situation) {
        switch situation {
        case .noAuthorization:
            statementLabel.text = NSLocalizedString("No Authorization", comment: "")
            imageView.image = #imageLiteral(resourceName: "Photo")
        case .noPhoto:
            statementLabel.text = NSLocalizedString("No Authorization", comment: "")
            imageView.image = #imageLiteral(resourceName: "Photo")
        }
    }
}
