//
//  DetailPhotoCell.swift
//  Electo
//
//  Created by byung-soo kwon on 2017. 8. 8..
//  Copyright © 2017년 RodoPacaGiraffe. All rights reserved.
//

import UIKit
import Photos

class DetailPhotoCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    
    var requestID: PHImageRequestID?
    
    override func prepareForReuse() {
        deSelect()
    }
    
    func select() {
        thumbnailImageView.alpha = 0.5
        self.isSelected = true
    }
    
    func deSelect() {
        thumbnailImageView.alpha = 1.0
        self.isSelected = false
    }
}
