//
//  EmptyView.swift
//  Electo
//
//  Created by RodoPacaGiraffe on 2017. 8. 19..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let statusDisplayView: String = "StatusDisplayView"
}

class StatusDisplayView: UIView {
    @IBOutlet private var statementLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    class func instanceFromNib(status: Status, frame: CGRect) -> StatusDisplayView {
        guard let statusDisplayView = UINib(nibName: Constants.statusDisplayView, bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? StatusDisplayView else {
            return StatusDisplayView()
        }
        statusDisplayView.frame = frame
        statusDisplayView.setStatusDisplayView(accordingTo: status)
        
        return statusDisplayView
    }
    
    private func setStatusDisplayView(accordingTo status: Status) {
        switch status {
        case .noAuthorization:
            statementLabel.text = NSLocalizedString("No Authorization", comment: "")
            imageView.image = #imageLiteral(resourceName: "Photo")
        case .emptyPhotoToOrganize:
            statementLabel.text = NSLocalizedString("No Photo", comment: "")
            imageView.image = #imageLiteral(resourceName: "Photo")
        }
    }
}
